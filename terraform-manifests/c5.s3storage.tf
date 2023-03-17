# Declare the S3 bucket

resource "aws_s3_bucket" "psi-cricket" {
  bucket = "psi-cricket-${var.deployment_stage}"
  #acl = "private"
}

output "s3_bucket" {
    #value = aws_s3_bucket.psi-cricket-dev.id
    value = aws_s3_bucket.psi-cricket.id
}
