# SSM AMI Updater

data "aws_ami" "info" {
  filter {
    name   = "image-id"
    values = ["${var.ami}"]
  }
}

locals {
  ami = "${data.aws_ami.info.id}"
}

module "parameter" {
  source = "git::git@github.com:Jamie-BitFlight/terraform-aws-parameter-store.git?ref=bitflight/master"

  parameter_write = [{
    name      = "/${var.namespace}/${var.stage}/${var.name}/LatestAmi"
    value     = "${local.ami}"
    type      = "String"
    overwrite = "true"
  }]
}
