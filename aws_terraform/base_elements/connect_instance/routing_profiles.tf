# ============================================
# Routing Profiles
# ============================================
# Define how contacts are routed to agents
# Routing profiles specify which queues agents can handle and media concurrency

resource "aws_connect_routing_profile" "main" {
  for_each = { for profile in var.routing_profiles : profile.name => profile }

  instance_id               = aws_connect_instance.main.id
  name                      = each.value.name
  description               = each.value.description
  default_outbound_queue_id = aws_connect_queue.main[each.value.default_outbound_queue_name].queue_id

  # Media concurrency defines how many contacts of each type an agent can handle simultaneously
  dynamic "media_concurrencies" {
    for_each = each.value.media_concurrencies
    content {
      channel     = media_concurrencies.value.channel
      concurrency = media_concurrencies.value.concurrency
    }
  }

  # Queue configurations define priority and delay for each queue
  dynamic "queue_configs" {
    for_each = each.value.queue_configs
    content {
      channel  = queue_configs.value.channel
      delay    = queue_configs.value.delay
      priority = queue_configs.value.priority
      queue_id = aws_connect_queue.main[queue_configs.value.queue_name].queue_id
    }
  }

  tags = var.tags

  depends_on = [aws_connect_queue.main]
}
