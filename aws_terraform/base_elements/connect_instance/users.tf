# ============================================
# Admin User (Optional)
# ============================================
# Create an admin user with full permissions
# Admin user is created with default Admin security profile

resource "aws_connect_user" "admin" {
  count = var.create_admin_user ? 1 : 0

  instance_id = aws_connect_instance.main.id
  name        = var.admin_user.username
  password    = var.admin_user.password

  identity_info {
    email      = var.admin_user.email
    first_name = var.admin_user.first_name
    last_name  = var.admin_user.last_name
  }

  phone_config {
    phone_type              = "SOFT_PHONE"
    auto_accept             = false
    after_contact_work_time_limit = 0
  }

  # Use the default Admin security profile from the data source
  # If no admin profiles are found, this will fail - manual assignment required
  security_profile_ids = data.aws_connect_security_profiles.admin.security_profile_summary_list[*].id

  # Use a basic routing profile (will be created first)
  routing_profile_id = length(var.routing_profiles) > 0 ? aws_connect_routing_profile.main[var.routing_profiles[0].name].routing_profile_id : null

  tags = var.tags

  depends_on = [
    aws_connect_routing_profile.main,
    aws_connect_security_profile.main
  ]
}

# Get default Admin security profile
data "aws_connect_security_profiles" "admin" {
  instance_id = aws_connect_instance.main.id
}

# ============================================
# Users
# ============================================
# Create users with specified configurations
# Users are agents who handle contacts in the contact center

resource "aws_connect_user" "main" {
  for_each = { for user in var.users : user.username => user }

  instance_id = aws_connect_instance.main.id
  name        = each.value.username
  password    = each.value.password

  identity_info {
    email      = each.value.email
    first_name = each.value.first_name
    last_name  = each.value.last_name
  }

  phone_config {
    phone_type                    = each.value.phone_type
    auto_accept                   = each.value.auto_accept
    after_contact_work_time_limit = each.value.after_contact_work_time
    desk_phone_number             = each.value.desk_phone_number
  }

  # Assign security profiles
  security_profile_ids = [
    for profile_name in each.value.security_profile_names : aws_connect_security_profile.main[profile_name].security_profile_id
  ]

  # Assign routing profile
  routing_profile_id = aws_connect_routing_profile.main[each.value.routing_profile_name].routing_profile_id

  # Hierarchy group assignment (optional)
  hierarchy_group_id = each.value.hierarchy_group_name != null ? aws_connect_user_hierarchy_group.main[each.value.hierarchy_group_name].hierarchy_group_id : null

  tags = var.tags

  depends_on = [
    aws_connect_routing_profile.main,
    aws_connect_security_profile.main
  ]
}

# ============================================
# User Hierarchy Groups (Optional)
# ============================================
# Create hierarchy groups for organizational structure
# Hierarchy groups allow you to organize users into teams/departments

locals {
  # Extract unique hierarchy group names from users
  hierarchy_groups = distinct(compact([for user in var.users : user.hierarchy_group_name if user.hierarchy_group_name != null]))
}

resource "aws_connect_user_hierarchy_group" "main" {
  for_each = toset(local.hierarchy_groups)

  instance_id = aws_connect_instance.main.id
  name        = each.value

  tags = var.tags
}
