variable "namespace" {
  default = "default"
}

variable "stage" {
  default = "default"
}

variable "name" {
  default = "default"
}

variable "region" {
  default = "eu-west-2"
}

variable "new_ami_sns_topic_arns" {
  type        = "list"
  description = "A list of strings of the ARN's of the SNS topics used to trigger a build. Defaults to the Amazon Linux topic."
  default     = ["arn:aws:sns:us-east-1:137112412989:amazon-linux-ami-updates"]
}

provider "aws" {
  region = "${var.region}"

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

data "aws_ami" "amazonlinux_ami" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
}

module "amazon_ami_bakery" {
  source    = "../../"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "${var.name}"
  ami       = "${data.aws_ami.amazonlinux_ami.id}"
}

# For Amazon Linux updates, they are only released in an SNS feed from us-east-1
# Pin a provider to us-east-1 to create a topic subscription to that SNS feed.
# Below we are subscribing the lambda function to this release notification, 
# This means that on each release from amazon, we will update our custom image to match.

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

resource "aws_sns_topic_subscription" "subscribe_automation" {
  provider  = "aws.us-east-1"
  count     = "${length(var.new_ami_sns_topic_arns)}"
  topic_arn = "${element(var.new_ami_sns_topic_arns, count.index)}"
  protocol  = "lambda"
  endpoint  = "${module.amazon_ami_bakery.lambda_endpoint_arn}"
}

# Generate a random hash, but the hash could be the sha256 of a lambda function easily enough.
resource "random_string" "unique" {
  length  = 8
  special = false
  lower   = true
  upper   = false
  number  = false
}

# Trigger it to run now
resource "aws_sns_topic" "default" {
  name_prefix = "Automation-Trigger"
}

resource "aws_sns_topic_subscription" "run_automation_sns" {
  topic_arn = "${aws_sns_topic.default.arn}"
  protocol  = "lambda"
  endpoint  = "${module.amazon_ami_bakery.lambda_endpoint_arn}"
}

module "run_automation_sns" {
  source        = "git::https://github.com/bitflight-public/terraform-aws-sns-topic-notify.git?ref=master"
  namespace     = "${var.namespace}"
  stage         = "${var.stage}"
  name          = "${var.name}-notify"
  sns_topic_arn = "${aws_sns_topic.default.arn}"
  trigger_hash  = "${random_string.unique.result}"
}
