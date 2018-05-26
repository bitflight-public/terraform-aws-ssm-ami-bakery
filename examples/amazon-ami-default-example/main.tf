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

variable "tags" {
  type    = "map"
  default = {}
}

variable "parameter_write" {
  default = []
  type    = "list"
}

variable "parameter_read" {
  type    = "list"
  default = []
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

## Subscribe the Lambda Function to an SNS Topic to trigger the build
## -> Extra AWS Provider pinned here, because the SNS topic subscription needs to be in the same region as the topic.
## -> The default AWS update topic is in us-east-1

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

resource "aws_sns_topic_subscription" "trigger_automation" {
  provider  = "aws.us-east-1"
  count     = "${length(var.new_ami_sns_topic_arns)}"
  topic_arn = "${element(var.new_ami_sns_topic_arns, count.index)}"
  protocol  = "lambda"
  endpoint  = "${module.amazon_ami_bakery.lambda_endpoint_arn}"
}