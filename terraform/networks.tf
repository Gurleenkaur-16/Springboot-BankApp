resource "aws_vpc" "gurleen_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "gurleen-vpc"
  }
}

resource "aws_subnet" "gurleen_subnet" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.gurleen_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                     = "gurleen-subnet-${count.index + 1}"
    "kubernetes.io/role/elb" = "1"
  }
}

#internet gateway
resource "aws_internet_gateway" "gurleen_igw" {
  vpc_id = aws_vpc.gurleen_vpc.id

  tags = {
    Name = "gurleen-igw"
  }
}

#route table
resource "aws_route_table" "gurleen_route_table" {
  vpc_id = aws_vpc.gurleen_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gurleen_igw.id
  }
  tags = {
    Name = "gurleen-route-table"
  }
}

#route table association
resource "aws_route_table_association" "gurleen_rta" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.gurleen_subnet[count.index].id
  route_table_id = aws_route_table.gurleen_route_table.id
}