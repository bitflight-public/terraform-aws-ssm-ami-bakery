variable "namespace" {
  description = "Namespace (e.g. `cp` or `cloudposse`) - required for `label` module"
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging` - required for `label` module"
}

variable "name" {
  description = "Name  (e.g. `bastion` or `db`) - required for `label` module"
}

variable "delimiter" {
  default = "-"
}

variable "attributes" {
  description = "Additional attributes (e.g. `policy` or `role`)"
  type        = "list"
  default     = []
}

variable "tags" {
  description = "Additional tags"
  type        = "map"
  default     = {}
}

variable "enabled" {
  description = "Enable the label"
  default     = "true"
}

module "label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.1.2"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  attributes = "${var.attributes}"
  delimiter  = "${var.delimiter}"
  tags       = "${var.tags}"
  enabled    = "${var.enabled == true || var.enabled == "true" ? "true" : "false"}"
}
