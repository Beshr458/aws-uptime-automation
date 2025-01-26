resource "aws_cloudwatch_event_rule" "this" {
  description         = var.description
  name                = var.name
  schedule_expression = var.cron
  state               = var.enable
}

resource "aws_cloudwatch_event_target" "target" {
  arn       = aws_lambda_function.this.arn
  rule      = aws_cloudwatch_event_rule.this.name
  target_id = var.name
}