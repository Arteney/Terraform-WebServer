terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# # Kreiranje vpc-a

resource "aws_vpc" "prod-vpc" {
   cidr_block = "10.0.0.0/16"
   tags = {
     Name = "production"
   }
 }

# # Kreiranje Internet Gateway-a

 resource "aws_internet_gateway" "gw" {
   vpc_id = aws_vpc.prod-vpc.id

 }

# # Kreiranje Custom Route Table

 resource "aws_route_table" "prod-route-table" {
   vpc_id = aws_vpc.prod-vpc.id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.gw.id
   }

   route {
     ipv6_cidr_block = "::/0"
     gateway_id      = aws_internet_gateway.gw.id
   }

   tags = {
     Name = "Prod"
   }
 }

# # Kreiranje Subnet-a

 resource "aws_subnet" "subnet-1" {
   vpc_id            = aws_vpc.prod-vpc.id
   cidr_block        = "10.0.1.0/24"
   availability_zone = "us-east-1a"

   tags = {
     Name = "prod-subnet"
   }
 }

# # Povezivanje subneta sa Route Table

 resource "aws_route_table_association" "a" {
   subnet_id      = aws_subnet.subnet-1.id
   route_table_id = aws_route_table.prod-route-table.id
 }

# # Kreiranje Security Grupa za port 22,80,443
 resource "aws_security_group" "allow_web" {
   name        = "allow_web_traffic"
   description = "Allow Web inbound traffic"
   vpc_id      = aws_vpc.prod-vpc.id

   ingress {
     description = "HTTPS"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
     description = "HTTP"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
     Name = "allow_web"
   }
 }

# # Kreiranje network interface-a sa ip adresom iz subneta

 resource "aws_network_interface" "web-server-nic" {
   subnet_id       = aws_subnet.subnet-1.id
   private_ips     = ["10.0.1.50"]
   security_groups = [aws_security_group.allow_web.id]
 }

# # Elastic IP za network interface

 resource "aws_eip" "one" {
   vpc                       = true
   network_interface         = aws_network_interface.web-server-nic.id
   associate_with_private_ip = "10.0.1.50"
   depends_on                = [aws_internet_gateway.gw]
 }


# # web server

 resource "aws_instance" "web-server-instance" {
   ami               = "ami-090fa75af13c156b4"
   instance_type     = "t2.micro"
   availability_zone = "us-east-1a"
   key_name          = "main-key"

   network_interface {
     device_index         = 0
     network_interface_id = aws_network_interface.web-server-nic.id
   }

   user_data = <<-EOF
                 #!/bin/bash
                 sudo yum install httpd -y
                 sudo systemctl start httpd
                 sudo systemctl enable httpd
                 sudo echo "<h1> TEST <h1>" >> /var/www/html/index.html
                 EOF

   tags = {
     Name = "web-server"
   }
 }



 

