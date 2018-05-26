resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${module.label.id}-profile"
  role = "${aws_iam_role.role.name}"
}

data "aws_iam_policy_document" "ssm_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "ssm.amazonaws.com", "lambda.amazonaws.com", "sns.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ssm_role_passrole" {
  statement {
    actions   = ["iam:GetRole", "iam:PassRole"]
    resources = ["${aws_iam_role.role.arn}"]
  }
}

resource "aws_iam_role" "role" {
  name = "${module.label.id}-role"
  path = "/"

  assume_role_policy = "${data.aws_iam_policy_document.ssm_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "attach_ssm_automation" {
  role       = "${aws_iam_role.role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}

resource "aws_iam_role_policy_attachment" "attach_ec2_role" {
  role       = "${aws_iam_role.role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "attach_lambda_role" {
  role       = "${aws_iam_role.role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

resource "aws_iam_policy" "policy_passrole" {
  name        = "${module.label.id}-passrole-policy"
  description = "${module.label.id}"
  policy      = "${data.aws_iam_policy_document.ssm_role_passrole.json}"
}

resource "aws_iam_role_policy_attachment" "attach_passrole" {
  role       = "${aws_iam_role.role.name}"
  policy_arn = "${aws_iam_policy.policy_passrole.arn}"
}

resource "aws_iam_role_policy_attachment" "attach_additional" {
  count      = "${length(var.additional_role_arns)}"
  role       = "${aws_iam_role.role.name}"
  policy_arn = "${element(var.additional_role_arns, count.index)}"
}
