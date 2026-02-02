# ============================================
# Contact Flows
# ============================================
# Create contact flows for call routing logic
# Contact flows define the customer experience and call flow logic

resource "aws_connect_contact_flow" "main" {
  for_each = { for flow in var.contact_flows : flow.name => flow }

  instance_id = aws_connect_instance.main.id
  name        = each.value.name
  description = each.value.description
  type        = each.value.type

  # Use inline content or read from file
  content = each.value.content != null ? each.value.content : (
    each.value.filename != null ? file(each.value.filename) : null
  )

  tags = var.tags
}
