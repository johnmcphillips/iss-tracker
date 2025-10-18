output "iss_data_url" {
  value = aws_s3_bucket.iss_tracker_bucket.bucket_regional_domain_name
}

output "iss_tracker_url" {
  value = "https://${aws_s3_bucket.iss_tracker_bucket.bucket_regional_domain_name}/index.html"
}