resource "aws_lambda_function" "this" {
  filename      = var.lambda_code
  function_name = var.name
  role          = var.role_arn
  handler       = var.handler

  source_code_hash = var.lambda_code_hash
  timeout          = var.lambda_timeout
  runtime          = var.runtime
  environment {
    variables = var.lambda_variables
  }
  depends_on = [
    aws_cloudwatch_log_group.this,
  ]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}