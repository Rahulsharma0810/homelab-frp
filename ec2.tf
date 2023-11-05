# Define a key pair for SSH access
resource "aws_key_pair" "instance_key_pair" {
  key_name   = "271.Machines.pub"                                # Replace with your SSH key pair name
  public_key = file("/Users/rvs/.ssh/271_LABS/271.Machines.pub") # Replace with your SSH key pair public key
}

# Define an EC2 instance
resource "aws_instance" "frps_instance" {
  ami                    = "ami-0a31c2002672717b6"
  instance_type          = "t4g.nano"
  subnet_id              = aws_subnet.subnet_ap_south_1.id
  key_name               = aws_key_pair.instance_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get -y install wget
  EOF

  tags = {
    Name = "frps"
  }
}

# Associate the security group with the network interface of the EC2 instance
resource "aws_network_interface_sg_attachment" "example" {
  security_group_id    = aws_security_group.allow_ssh.id
  network_interface_id = aws_instance.frps_instance.primary_network_interface_id
}


resource "aws_ec2_instance_connect_endpoint" "ec2_connect_endpoint" {
  subnet_id          = aws_subnet.subnet_ap_south_1.id
  security_group_ids = [aws_security_group.allow_ssh.id]
}

# resource "aws_instance_connect_instance" "" {
#   instance_id           = aws_instance.frps_instance.id
#   instance_connect_name = aws_instance_connect.ec2_connect.name
# }
