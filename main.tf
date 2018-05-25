# SSM AMI Updater

# By default, start with base AMI image, otherwise incrementally update the image.
# Create a role with policies allowing running this automation from SSM
# Name the image
# Submodule: Allow setting expiry of old images
# Submodule: Look for launch configurations and launch templates with the old image and output them
# 

/*
"arn:aws:lambda:*:*:function:Automation*"
*/

# data "aws_caller_identity" "default" {}
# data "aws_region" "default" {}
# data "aws_region" "default" {}

# data "aws_subnet" "default" {
#   id = "${var.subnet == "" ? data.aws_subnet_ids.all.ids[0] : var.subnet }"
# }
# data "aws_subnet_ids" "all" {
#   vpc_id = "${data.aws_vpc.default.id}"
# }
# data "aws_vpc" "default" {
#   default = true
# }

data "aws_ami" "default" {
  most_recent = "true"

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "aws_ami" "info" {
  filter {
    name   = "image-id"
    values = ["${local.ami}"]
  }
}

resource "aws_ssm_activation" "activate" {
  name               = "test_ssm_activation"
  description        = "Test"
  iam_role           = "${aws_iam_role.role.id}"
  registration_limit = "5"
  depends_on         = ["aws_iam_role_policy_attachment.attach_ssm_automation"]
}

module "parameter" {
  source = "../terraform-aws-parameter-store"

  parameter_write = [{
    name      = "/${var.namespace}/${var.stage}/${var.name}/LatestAmi"
    value     = "${var.ami == "" ? data.aws_ami.default.id : var.ami}"
    type      = "String"
    overwrite = "true"
  }]
}
