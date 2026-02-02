# ============================================
# Queues
# ============================================
# Create queues for managing incoming contacts
# Queues hold contacts until an available agent can handle them

resource "aws_connect_queue" "main" {
  for_each = { for queue in var.queues : queue.name => queue }

  instance_id           = aws_connect_instance.main.id
  name                  = each.value.name
  description           = each.value.description
  hours_of_operation_id = aws_connect_hours_of_operation.main[each.value.hours_of_operation_name].hours_of_operation_id

  # Maximum contacts allowed in the queue
  max_contacts = each.value.max_contacts

  # Outbound caller ID configuration
  outbound_caller_config {
    outbound_caller_id_name = each.value.outbound_caller_id_name
    # Only set phone number if provided and phone number exists
    outbound_caller_id_number_id = each.value.outbound_caller_id_number_key != null ? aws_connect_phone_number.main[each.value.outbound_caller_id_number_key].phone_number_id : null
  }

  # Queue status (ENABLED or DISABLED)
  status = each.value.status

  # Quick connects allow agents to transfer calls easily
  quick_connect_ids = [
    for qc_key in each.value.quick_connect_keys : aws_connect_quick_connect.main[qc_key].quick_connect_id
  ]

  tags = var.tags

  depends_on = [
    aws_connect_hours_of_operation.main,
    aws_connect_phone_number.main,
    aws_connect_quick_connect.main
  ]
}
