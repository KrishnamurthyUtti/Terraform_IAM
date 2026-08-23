provider "aws" {
  region = "ap-south-1" # Change to your region
}

# Create IAM User
resource "aws_iam_user" "ec2_s3_user" {
  #name = length(var.username) > 0 ? var.username[2] : "default-ec2-s3-user"
  for_each = toset(var.username)
  name     = each.value
}

# Attach Policy for EC2 List + S3 Read
resource "aws_iam_user_policy" "ec2_s3_policy" {
  for_each = aws_iam_user.ec2_s3_user
  name     = "ec2-s3-read-policy"
  #user = aws_iam_user.ec2_s3_user.name
  user = each.value.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = [
          "ec2:DescribeInstances" # List EC2 instances
        ]
        Resource = "*"
      },
      {
        Effect = "Deny"
        Action = [
          "s3:GetObject", # Read objects
          "s3:ListBucket" # List bucket contents
        ]
        Resource = [
          "arn:aws:s3:::*", # All buckets
          "arn:aws:s3:::*/*"
        ]
      }
    ]
  })
}

# Create Access Keys for the User
resource "aws_iam_access_key" "ec2_s3_access_key" {
  for_each = aws_iam_user.ec2_s3_user
  #user = aws_iam_user.ec2_s3_user.name 
  user = each.value.name
}

output "iam_user_name" {
  value = [for user in aws_iam_user.ec2_s3_user : user.name]
}

output "iam_user_policy" {
  value = [for policy in aws_iam_user_policy.ec2_s3_policy : policy.policy]
}

output "access_key_id" {
  value = [for key in aws_iam_access_key.ec2_s3_access_key : key.id]
}


