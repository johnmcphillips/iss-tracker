provider "aws" {
  region = var.region
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "null_resource" "create_layer" {
    provisioner "local-exec" {
        interpreter = ["/bin/bash","-lc"]
        command = <<EOF
        set -euo pipefail
        rm -rf ${path.module}/lambda_get/.build && rm -rf ${path.module}/lambda_get/python &&
        mkdir -p ${path.module}/lambda_get/.build && mkdir -p ${path.module}/lambda_get/python &&
        python3 -m pip install -r ${path.module}/lambda_get/requirements.txt -t ${path.module}/lambda_get/python
        EOF
    }
}

data "archive_file" "lambda_requirements" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_get"
  output_path = "${path.module}/.build/requirements.zip"
  depends_on = [null_resource.create_layer]
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_get/app.py"
  output_path = "${path.module}/.build/app.zip"
}

resource aws_lambda_layer_version "lambda_library_layer" {
    filename          = data.archive_file.lambda_requirements.output_path
    layer_name        = "lambda_library_layer"
    compatible_runtimes = ["python3.12"]
}
resource "aws_lambda_function" "iss_tracker_lambda" {
  function_name = "ISS-Tracker-Lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.12"
  filename      = data.archive_file.lambda_zip.output_path
  layers        = [aws_lambda_layer_version.lambda_library_layer.arn]    
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
