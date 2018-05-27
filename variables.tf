# Label variables are stored in the labels.tf file for portibility.

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

variable "os_type" {
  type        = "string"
  default     = "linux"
  description = "Is the AMI of 'linux' or 'windows'"
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

variable "additional_userdata" {
  type        = "string"
  description = "User data for the build"
  default     = ""
}

variable "kms_key_arn" {
  type        = "string"
  description = "KMS Key for decrypting/encrypting SSM Parameter store values"
  default     = ""
}

variable "target_asg" {
  type        = "string"
  description = "Automatically update this autoscaling group arn to use the new AMI if they were using the old AMI"
  default     = ""
}

variable "approvers_list" {
  type        = "list"
  description = "A list of IAM roles or users that are required to approve the ASG deployment"
  default     = []
}

variable "min_num_approvers" {
  type        = "string"
  description = "The minimum number of users needed to approve the list. Defaults to 1"
  default     = "1"
}

variable "require_approval_to_update_asg" {
  type        = "string"
  description = "If true, an additional section is added to the automation that requires user approval in the AWS SSM console before updating the ASG"
  default     = "false"
}
