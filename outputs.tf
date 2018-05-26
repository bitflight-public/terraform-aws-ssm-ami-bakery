output "lambda_endpoint_arn" {
  value = "${aws_lambda_function.lambda_trigger_automation.arn}"
}

output "document_name" {
  value = "${var.os_type == "linux" ? join("",aws_ssm_document.document_linux.*.name) : "${var.os_type == "windows" ?  join("",aws_ssm_document.document_linux.*.name) : "none"}" }"
}

output "source_ami_id" {
  value = "${local.ami}"
}

output "target_ami_name" {
  value = "${local.target_ami_name}"
}

output "instance_iam_role" {
  value = "${aws_iam_instance_profile.ec2_profile.name}"
}

output "instance_type" {
  value = "${var.instance_type}"
}

output "pre_update_script_url" {
  value = "${var.pre_update_script_url}"
}

output "post_update_script_url" {
  value = "${var.post_update_script_url}"
}

output "include_packages" {
  value = "${var.include_packages}"
}

output "exclude_packages" {
  value = "${var.exclude_packages}"
}

output "source_ami_parameter_name" {
  value = "${join("",module.parameter.names)}"
}

output "source_ami_parameter_value" {
  value = "${join("",module.parameter.values)}"
}
