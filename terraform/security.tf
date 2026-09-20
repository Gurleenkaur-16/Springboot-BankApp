# Security group for the EKS control plane.
resource "aws_security_group" "gurleen_cluster_sg" {
  name   = "gurleen-cluster-sg"
  vpc_id = aws_vpc.gurleen_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "gurleen-cluster-sg" }
}

# Security group for worker nodes and SSH access.
resource "aws_security_group" "gurleen_node_sg" {
  name   = "gurleen-node-sg"
  vpc_id = aws_vpc.gurleen_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "gurleen-node-sg" }
}