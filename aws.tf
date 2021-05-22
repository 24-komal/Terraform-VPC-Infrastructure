#Ever wondered about launching the whole infrastructure in just one command, yes, it seems to be impossible, but it is possible. 

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

#Creating the VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC"
  }
}

#Creating Public Subnet where all the instances launched inside this subnet, will automatically be provided a public IP from which they will connect to the Internet Gateway.
resource "aws_subnet" "publicsubnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public_Subnet"
  }
}

#Creating the Private Subnet where we no Public IP will be allocated to any instance if launched in this subnet.
resource "aws_subnet" "privatesubnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Private_Subnet"
  }
}

#Creating the Internet Gateway and attaching it to VPC. 
#This Internet Gateway serves two purposes: to provide a target in your VPC route tables for internet-routable traffic, and to perform network address translation (NAT) for instances that have been assigned public IPv4 addresses.
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Internet_Gateway"
  }
}

#Creating the Internet Gateway is not just enough we have to create a new routing table for the "Public_Subnet" because by-default the routing table for the subnets inside the VPC can only connect to the instances which are inside the VPC basically means locally, so instead of updating it we will create a new Routing Table for the same. Here we will route our destination form anywhere in the world (0.0.0.0/0).
resource "aws_route_table" "route_gw" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Route_Table"
  }
}

#After creating we have to allocate it to our "Public_Subnet".
resource "aws_route_table_association" "instance1" {
  subnet_id = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.route_gw.id
}

#NAT devices is used to enable instances in a private subnet to connect to the internet (for example, for software updates) or other AWS services, but prevent the internet from initiating connections with the instances. So, for that we have to first create elastic IP.
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.publicsubnet.id

  tags = {
    Name = "NAT_Gateway"
  }
}

output "nat_gateway_ip" {
  value = aws_eip.nat.public_ip
}

#Now same as we done for the Internet Gateway we need to create a new Routing table for the Private Subnet too because by default it provides a rule for connecting to the local instances. 
resource "aws_route_table" "route_nat" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }
}

resource "aws_route_table_association" "instance2" {
  subnet_id = aws_subnet.privatesubnet.id
  route_table_id = aws_route_table.route_nat.id
}

#Now to automatically build our VPC, simply execute the terraform apply command.
#Just in one click your entire VPC infrastructure is been created.
