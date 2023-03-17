# Two user groups viz DE and DS with DE having Admin access and DS group having S3 read only access

# Declare the DE group
resource "aws_iam_group" "de_group" {
  name = "DE"
}

# Attach Admin Access Policy to DE Group
resource "aws_iam_group_policy_attachment" "de_group_admin_policy" {
  group = aws_iam_group.de_group.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Declare the DS group
resource "aws_iam_group" "ds_group" {
  name = "DS"
}

# Attach S3 ReadOnly Access Policy to DS Group
resource "aws_iam_group_policy_attachment" "ds_group_s3_policy" {
  group = aws_iam_group.ds_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
