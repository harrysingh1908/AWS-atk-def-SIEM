resource "aws_instance" "attacker" {
  ami                         = var.attacker_ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.attacker_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "SIEM-Attacker-Ubuntu"
    Role = "Attacker"
  }
}

resource "aws_instance" "linux_victim" {
  ami                         = var.linux_victim_ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.linux_victim_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "SIEM-Linux-Victim-Ubuntu"
    Role = "Linux-Victim"
  }
}

resource "aws_instance" "windows_victim" {
  ami                         = var.windows_victim_ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.windows_victim_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "SIEM-Windows-Victim"
    Role = "Windows-Victim"
  }
}