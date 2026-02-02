# ============================================
# Phone Numbers
# ============================================
# Provision phone numbers for the Connect instance
# Phone numbers can be used for inbound calls and outbound caller ID

resource "aws_connect_phone_number" "main" {
  for_each = var.phone_numbers

  country_code = each.value.country_code
  type         = each.value.type
  description  = each.value.description

  # Associate with Connect instance
  target_arn = aws_connect_instance.main.arn

  tags = merge(
    var.tags,
    {
      Name        = each.key
      Description = each.value.description
    }
  )
}
