# ============================================
# DynamoDB Backup Configuration
# ============================================

# AWS Backup vault for DynamoDB backups
resource "aws_backup_vault" "dynamodb" {
  count = var.enable_backup_vault ? 1 : 0

  name        = "${var.table_name}-backup-vault"
  kms_key_arn = var.backup_vault_kms_key_arn

  tags = merge(
    var.tags,
    {
      Name = "${var.table_name}-backup-vault"
    }
  )
}

# AWS Backup plan
resource "aws_backup_plan" "dynamodb" {
  count = var.enable_backup_plan ? 1 : 0

  name = "${var.table_name}-backup-plan"

  rule {
    rule_name         = "${var.table_name}-daily-backup"
    target_vault_name = var.enable_backup_vault ? aws_backup_vault.dynamodb[0].name : var.existing_backup_vault_name
    schedule          = var.backup_schedule

    lifecycle {
      delete_after = var.backup_retention_days
      cold_storage_after = var.backup_cold_storage_after_days
    }

    recovery_point_tags = merge(
      var.tags,
      {
        BackupPlan = "${var.table_name}-backup-plan"
      }
    )
  }

  dynamic "rule" {
    for_each = var.enable_weekly_backup ? [1] : []
    content {
      rule_name         = "${var.table_name}-weekly-backup"
      target_vault_name = var.enable_backup_vault ? aws_backup_vault.dynamodb[0].name : var.existing_backup_vault_name
      schedule          = "cron(0 2 ? * SUN *)"

      lifecycle {
        delete_after       = var.backup_weekly_retention_days
        cold_storage_after = var.backup_cold_storage_after_days
      }
    }
  }

  tags = var.tags
}

# IAM role for AWS Backup
resource "aws_iam_role" "backup" {
  count = var.enable_backup_plan ? 1 : 0

  name               = "${var.table_name}-backup-role"
  assume_role_policy = data.aws_iam_policy_document.backup_assume_role[0].json

  tags = var.tags
}

data "aws_iam_policy_document" "backup_assume_role" {
  count = var.enable_backup_plan ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Attach AWS managed backup policy
resource "aws_iam_role_policy_attachment" "backup" {
  count = var.enable_backup_plan ? 1 : 0

  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "backup_restore" {
  count = var.enable_backup_plan ? 1 : 0

  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# Backup selection
resource "aws_backup_selection" "dynamodb" {
  count = var.enable_backup_plan ? 1 : 0

  name         = "${var.table_name}-backup-selection"
  plan_id      = aws_backup_plan.dynamodb[0].id
  iam_role_arn = aws_iam_role.backup[0].arn

  resources = [
    aws_dynamodb_table.this.arn
  ]
}

# On-demand backup (manual)
resource "aws_dynamodb_table_backup" "manual" {
  count = var.create_manual_backup ? 1 : 0

  table_name = aws_dynamodb_table.this.name
  name       = "${var.table_name}-manual-backup-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
}
