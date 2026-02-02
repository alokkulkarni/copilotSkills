# ============================================
# IAM Role for Connect Instance
# ============================================
# Create IAM role for Connect instance to access other AWS services
# This role is used for service integrations like Lex, Lambda, and S3

data "aws_iam_policy_document" "connect_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["connect.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "connect_instance" {
  name               = "${var.instance_alias}-connect-instance-role"
  assume_role_policy = data.aws_iam_policy_document.connect_assume_role.json

  tags = var.tags
}

# Attach AWS managed policy for Connect access to common services
# Can be overridden with a custom policy ARN via connect_iam_policy_arn variable
# Set connect_iam_policy_arn to empty string to skip managed policy attachment
resource "aws_iam_role_policy_attachment" "connect_service_policy" {
  count = var.connect_iam_policy_arn != "" ? 1 : 0

  role       = aws_iam_role.connect_instance.name
  policy_arn = var.connect_iam_policy_arn
}
