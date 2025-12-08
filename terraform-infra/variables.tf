variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "key_pair_name" {
  description = "Existing key pair of EC2"
  type        = string
  default     = "siem_key"  
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "attacker_ami_id" {
  description = "AMI ID for Attacker instance"
  type        = string
}

variable "linux_victim_ami_id" {
  description = "AMI ID for Linux Victim instance"
  type        = string
}

variable "windows_victim_ami_id" {
  description = "AMI ID for Windows Victim instance"
  type        = string
}
