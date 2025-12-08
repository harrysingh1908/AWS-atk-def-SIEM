output "aws_region" {
  description = "The AWS region where resources are deployed"
  value       = var.region
}

output "attacker_public_ip" {
  description = "Public IP of the Attacker EC2 instance"
  value       = aws_instance.attacker.public_ip
}

output "linux_victim_public_ip" {
  description = "Public IP of the Linux Victim EC2 instance"
  value       = aws_instance.linux_victim.public_ip
}

output "windows_victim_public_ip" {
  description = "Public IP of the Windows Victim EC2 instance"
  value       = aws_instance.windows_victim.public_ip
}