# ============================================
# Security Profiles
# ============================================
# Define permissions for users
# Security profiles control what actions users can perform in Connect

resource "aws_connect_security_profile" "main" {
  for_each = { for profile in var.security_profiles : profile.name => profile }

  instance_id = aws_connect_instance.main.id
  name        = each.value.name
  description = each.value.description

  # Permissions determine what actions users with this profile can perform
  permissions = each.value.permissions

  tags = var.tags
}
