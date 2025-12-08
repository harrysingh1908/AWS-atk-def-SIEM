resource "aws_security_group" "attacker_sg" {
  name        = "siem_attacker_sg"
  description = "Security group for attacker machines"
  vpc_id      = aws_vpc.siem_vpc.id

  ingress {
    description = "Allows SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SIEM_Attacker_SG"
  }
}

resource "aws_security_group" "linux_victim_sg" {
  name        = "siem_linux_victim_sg"
  description = "Security group for Linux victim"
  vpc_id      = aws_vpc.siem_vpc.id

  ingress {
    description = "Allows SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SIEM_Linux_Victim_SG"
  }
}

resource "aws_security_group" "windows_victim_sg" {
  name        = "siem_windows_victim_sg"
  description = "Security group for Windows victim"
  vpc_id      = aws_vpc.siem_vpc.id

  ingress {
    description = "Allows RDP from anywhere"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SIEM_Windows_Victim_SG"
  }
}