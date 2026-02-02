# ============================================
# Quick Connects
# ============================================
# Create quick connects for fast transfers and callbacks
# Quick connects allow agents to quickly transfer to queues, users, or external numbers

resource "aws_connect_quick_connect" "main" {
  for_each = var.quick_connects

  instance_id = aws_connect_instance.main.id
  name        = each.value.name
  description = each.value.description

  quick_connect_config {
    quick_connect_type = each.value.type

    # Phone number configuration for external transfers
    dynamic "phone_config" {
      for_each = each.value.type == "PHONE_NUMBER" ? [1] : []
      content {
        phone_number = each.value.phone_number
      }
    }

    # Queue configuration for queue transfers
    dynamic "queue_config" {
      for_each = each.value.type == "QUEUE" ? [1] : []
      content {
        contact_flow_id = aws_connect_instance.main.id # Default flow
        queue_id        = aws_connect_queue.main[each.value.queue_name].queue_id
      }
    }

    # User configuration for agent transfers
    dynamic "user_config" {
      for_each = each.value.type == "USER" ? [1] : []
      content {
        contact_flow_id = aws_connect_instance.main.id # Default flow
        user_id         = aws_connect_user.main[each.value.user_name].user_id
      }
    }
  }

  tags = var.tags

  depends_on = [
    aws_connect_queue.main,
    aws_connect_user.main
  ]
}
