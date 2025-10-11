provider "aws" {
  region = var.region
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_get"
  output_path = "${path.module}/.build/app.zip"
}

resource "aws_lambda_function" "iss_tracker_lambda" {
  function_name = "ISS-Tracker-Lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "main.handler"
  runtime       = "python3.10"
  filename      = data.archive_file.lambda_zip.output_path
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_s3_bucket" "iss_tracker_bucket" {
  bucket = "iss-tracker-${random_id.bucket_id.hex}"
}
