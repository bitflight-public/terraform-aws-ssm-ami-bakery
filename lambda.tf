resource "aws_lambda_function" "lambda" {
  filename         = "lambda.zip"
  function_name    = "${module.label.id}-ssm-function"
  role             = "${aws_iam_role.role.arn}"
  handler          = "lambda_handler"
  source_code_hash = "${base64sha256(file("lambda.zip"))}"
  runtime          = "python2.7"
  tags             = "${module.label.tags}"

  # vpc_config {}
  # kms_key_arn = "${var.kms_key_arn}"
}
