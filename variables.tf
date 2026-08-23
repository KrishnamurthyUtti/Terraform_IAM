variable "username" {
  description = "aws usernames"
  type        = list(any)
  default     = ["ec2-s3-user1", "ec2-s3-user2", "ec2-s3-user3"]
}