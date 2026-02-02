# ============================================
# Lambda Function Associations
# ============================================
# Associate Lambda functions with the Connect instance
# Lambda functions can be invoked from contact flows for custom logic

resource "aws_connect_lambda_function_association" "main" {
  for_each = var.lambda_functions

  instance_id  = aws_connect_instance.main.id
  function_arn = each.value.function_arn
}

# Grant Connect permission to invoke the Lambda functions
resource "aws_lambda_permission" "connect_invoke" {
  for_each = var.lambda_functions

  statement_id  = "AllowConnectInvoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_arn
  principal     = "connect.amazonaws.com"
  source_arn    = aws_connect_instance.main.arn
}

# ============================================
# Lex Bot Associations
# ============================================
# Associate Lex bots with the Connect instance
# Lex bots provide conversational AI capabilities in contact flows

data "aws_region" "current" {}

resource "aws_connect_bot_association" "main" {
  for_each = { for bot in var.lex_bots : bot.name => bot }

  instance_id = aws_connect_instance.main.id

  lex_bot {
    name       = each.value.name
    lex_region = each.value.lex_region != null ? each.value.lex_region : data.aws_region.current.name
  }
}
