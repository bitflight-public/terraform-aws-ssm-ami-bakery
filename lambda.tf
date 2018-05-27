data "archive_file" "lambda_update_parameter_store" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda-update-parameter-store.py"
  output_path = "${path.module}/lambda/lambda-update-parameter-store.zip"
}

resource "aws_lambda_function" "lambda_update_parameter_store" {
  filename         = "${data.archive_file.lambda_update_parameter_store.output_path}"
  function_name    = "${module.label.id}-update-parameter-store"
  role             = "${aws_iam_role.role.arn}"
  handler          = "lambda-update-parameter-store.lambda_handler"
  source_code_hash = "${data.archive_file.lambda_update_parameter_store.output_base64sha256}"
  runtime          = "python2.7"
  tags             = "${module.label.tags}"
  timeout          = "15"

  # vpc_config {}
  kms_key_arn = "${var.kms_key_arn}"
}

data "archive_file" "lambda_update_asg" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda-update-autoscaling-groups.py"
  output_path = "${path.module}/lambda/lambda-update-autoscaling-groups.zip"
}

resource "aws_lambda_function" "lambda_update_asg" {
  filename         = "${data.archive_file.lambda_update_asg.output_path}"
  function_name    = "${module.label.id}-update-asg"
  role             = "${aws_iam_role.role.arn}"
  handler          = "lambda-update-parameter-store.lambda_handler"
  source_code_hash = "${data.archive_file.lambda_update_asg.output_base64sha256}"
  runtime          = "python2.7"
  tags             = "${module.label.tags}"
  timeout          = "15"

  kms_key_arn = "${var.kms_key_arn}"
}

locals {
  target_ami_name = "${var.target_ami_name_override != "" ? var.target_ami_name_override : "${module.label.id}-{{global:DATE_TIME}}"}"
}

data "archive_file" "lambda_trigger_automation" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda-trigger-automation.py"
  output_path = "${path.module}/lambda/lambda-trigger-automation.zip"
}

resource "aws_lambda_function" "lambda_trigger_automation" {
  filename         = "${data.archive_file.lambda_trigger_automation.output_path}"
  function_name    = "${module.label.id}-trigger-automation"
  role             = "${aws_iam_role.role.arn}"
  handler          = "lambda-trigger-automation.lambda_handler"
  source_code_hash = "${data.archive_file.lambda_trigger_automation.output_base64sha256}"
  runtime          = "python2.7"
  tags             = "${module.label.tags}"
  timeout          = "15"

  # vpc_config {}
  kms_key_arn = "${var.kms_key_arn}"

  environment {
    variables = {
      DocumentName             = "${var.os_type == "linux" ? join("",aws_ssm_document.document_linux.*.name) : "${var.os_type == "windows" ?  join("", aws_ssm_document.document_linux.*.name) : "none"}" }"
      SourceAmiId              = "${local.ami}"
      InstanceIamRole          = "${aws_iam_instance_profile.ec2_profile.name}"
      AutomationAssumeRole     = "${aws_iam_role.role.arn}"
      TargetAmiName            = "${local.target_ami_name}"
      InstanceType             = "${var.instance_type}"
      PreUpdateScript          = "${var.pre_update_script_url}"
      PostUpdateScript         = "${var.post_update_script_url}"
      IncludePackages          = "${var.include_packages}"
      ExcludePackages          = "${var.exclude_packages}"
      SSMAmiLambdaFunctionName = "${aws_lambda_function.lambda_update_parameter_store.function_name}"
      SourceAmiParameterName   = "${join("",module.parameter.names)}"
      SSMAutomationUpdateAsg   = "${aws_lambda_function.lambda_update_asg.function_name}"
      targetASG                = "${var.target_asg}"
    }
  }
}
