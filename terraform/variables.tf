variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "my_ip" {
  description = "Your public IP with /32 for SSH access to bastion"
  type        = string
}