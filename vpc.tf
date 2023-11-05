# Define the VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "main"
  }
}

# Create an internet gateway for internet access
resource "aws_internet_gateway" "main_gw" {
  vpc_id = aws_vpc.main.id
}

# Define a route table for the VPC
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "rt-main"
  }

  # Add a default route for internet access
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gw.id
  }
}

# Define a subnet within the VPC
resource "aws_subnet" "subnet_ap_south_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
}

resource "aws_route_table_association" "rt_subnet" {
  depends_on     = [aws_route_table.main, aws_subnet.subnet_ap_south_1]
  route_table_id = aws_route_table.main.id
  subnet_id      = aws_subnet.subnet_ap_south_1.id
}

# Define a security group allowing SSH access
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  # Allow SSH from your IP and all other IPs (for testing)
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["49.47.69.116/32", "0.0.0.0/0"]
  }
  ingress {
    description = "Web from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# # Define an Elastic IP for the instance
# resource "aws_eip" "frps_eip" {
#   domain = "vpc"
#   tags = {
#     Name = "frps_eip"
#   }
# }

# resource "aws_eip_association" "eip_assoc" {
#   instance_id   = aws_instance.frps_instance.id
#   allocation_id = aws_eip.frps_eip.id
# }
