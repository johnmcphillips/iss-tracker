provider "aws" {
  region = var.region
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "iss_tracker_bucket" {
  bucket        = "iss-tracker-${random_id.bucket_id.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "allow_public_access" {
  bucket                  = aws_s3_bucket.iss_tracker_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "site_s3" {
  bucket = aws_s3_bucket.iss_tracker_bucket.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "site_s3_policy" {
  bucket     = aws_s3_bucket.iss_tracker_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.allow_public_access]
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:GetObject"]
        Resource  = "${aws_s3_bucket.iss_tracker_bucket.arn}/*"
      }
    ]
  })
}