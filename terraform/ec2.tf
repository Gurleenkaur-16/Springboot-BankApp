#security group
resource "aws_security_group" "gurleen_sg" {
  vpc_id = aws_vpc.gurleen_vpc.id

  ingress {
    description = "SSH"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "gurleen-sg"
  }
}
#instance
resource "aws_instance" "gurleen_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  key_name = var.key_name

  subnet_id = aws_subnet.gurleen_subnet[0].id

  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.gurleen_sg.id
  ]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "gurleen-instance"
  }
}
