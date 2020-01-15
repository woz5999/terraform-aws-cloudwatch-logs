provider "aws" {
}

module "role" {
  source = "git::https://github.com/woz5999/terraform-aws-iam-role.git?ref=upgrade-0.12"

  enabled = var.enabled

  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = compact(concat(var.attributes, ["log"], ["group"]))
  tags       = var.tags

  role_description   = "Cloudwatch ${module.label.id} logs role"
  policy_description = "Cloudwatch ${module.label.id} logs policy"

  principals = var.principals

  policy_documents = [
    data.aws_iam_policy_document.log_agent.json,
  ]
}

data "aws_iam_policy_document" "log_agent" {
  statement {
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "logs:PutLogEvents",
    ]

    resources = aws_cloudwatch_log_group.default.*.arn
  }

  statement {
    actions = var.additional_permissions

    resources = aws_cloudwatch_log_group.default.*.arn
  }
}

