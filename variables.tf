# Label variables are stored in the labels.tf file for portibility.

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
  type = "list"

  description = <<EOF
A list of AWS authenticated principals who are able to either approve or reject the action. 
The maximum number of approvers is 10. 
You can specify principals by using any of the following formats:
- An AWS Identity and Access Management (IAM) user name
- An IAM user ARN
- An IAM role ARN
- An IAM assume role user ARN
EOF

  default = []
}

variable "min_num_approvers" {
  type = "string"

  description = <<EOF
The minimum number of approvals required to resume the Automation execution. 
If you don't specify a value, the system defaults to one. The value for this parameter must be a positive number. 
The value for this parameter can't exceed the number of approvers defined by the Approvers parameter.
Defaults to 1"
EOF

  default = "1"
}

variable "require_approval_to_update_asg" {
  type        = "string"
  description = "If true, an additional section is added to the automation that requires user approval in the AWS SSM console before updating the ASG"
  default     = "false"
}
