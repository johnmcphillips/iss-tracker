resource "aws_cloudwatch_event_rule" "one_minute" {
  name                = "iss-tracker-1-minute"
  description         = "Fires every 1 minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.one_minute.name
  target_id = "iss-lambda"
  arn       = aws_lambda_function.iss_tracker_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.iss_tracker_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.one_minute.arn
}