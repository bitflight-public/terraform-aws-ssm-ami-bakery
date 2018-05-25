variable "namespace" {
  description = "Namespace (e.g. `cp` or `cloudposse`) - required for `tf_label` module"
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging` - required for `tf_label` module"
}

variable "name" {
  description = "Name  (e.g. `bastion` or `db`) - required for `tf_label` module"
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
  description = "When set to true, the resources in this module will be created"
  type        = "string"
  default     = "true"
}

variable "subnet" {
  type        = "string"
  description = "Which subnet should the AMI be in when building"
  default     = ""
}

variable "ami" {
  type        = "string"
  description = "Which base AMI should this module use"
  default     = ""
}

variable "additional_role_arns" {
  type        = "list"
  description = "A list of additional role ARNs to attach to the SSM role, that is also attached to the AMI while it builds."
  default     = []
}

variable "target_ami_name_override" {
  type        = "string"
  description = "By default the generated AMI name is based on the format of the terraform-null-label id. This can be used to override that."
  default     = ""
}

variable "instance_type" {
  type        = "string"
  description = "Which instance type should be used to build the AMI"
  default     = "t2.small"
}

variable "include_packages" {
  type        = "string"
  description = "Only update these named packages. Defaults to 'all' packages."
  default     = "all"
}

variable "exclude_packages" {
  type        = "string"
  description = "Exclude these named packages. Defaults to 'none'"
  default     = "none"
}

variable "pre_update_script_url" {
  type        = "string"
  description = "URL of a script to run before updates are applied. Default ('none') is to not run a script"
  default     = "none"
}

variable "post_update_script_url" {
  type        = "string"
  description = "URL of a script to run after package updates are applied. Default ('none') is to not run a script."
  default     = "none"
}

variable "activate" {
  type        = "string"
  description = "If set to true, a build will be run now"
  default     = "false"
}

variable "userdata" {
  type        = "string"
  description = "User data for the build"
  default     = ""
}
