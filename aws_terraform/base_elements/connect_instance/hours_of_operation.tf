# ============================================
# Hours of Operation
# ============================================
# Define business hours for queues and routing
# These determine when agents are available and when to use after-hours flows

resource "aws_connect_hours_of_operation" "main" {
  for_each = { for hours in var.hours_of_operation : hours.name => hours }

  instance_id = aws_connect_instance.main.id
  name        = each.value.name
  description = each.value.description
  time_zone   = each.value.time_zone

  dynamic "config" {
    for_each = each.value.config
    content {
      day = config.value.day

      start_time {
        hours   = config.value.start_time.hours
        minutes = config.value.start_time.minutes
      }

      end_time {
        hours   = config.value.end_time.hours
        minutes = config.value.end_time.minutes
      }
    }
  }

  tags = var.tags
}
