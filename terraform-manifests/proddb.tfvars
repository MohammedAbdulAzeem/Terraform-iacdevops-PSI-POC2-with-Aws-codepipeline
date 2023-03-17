# Declare the DynamoDB table
resource "aws_dynamodb_table" "psi_table" {
  name = "Cricket_Match_List-Prod"
  billing_mode   = "PROVISIONED"
  hash_key = "Match_ID"
  range_key = "Match Location"
  read_capacity  = 10
  write_capacity = 10
  attribute {
    name = "Match_ID"
    type = "N"
  }
  attribute {
    name = "Match Location"
    type = "S"
  }
}