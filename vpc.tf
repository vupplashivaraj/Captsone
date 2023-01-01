# Create VPC
resource "aws_vpc" "vpc" {
 cidr_block = "10.0.0.0/16"
 
 tags = {
   Name = "upgrad-project-VPC"
 }
}

# Create an EKS variable for tagging the subnets
variable "name" {}
variable "eks_cluster_name" { default = "" }

locals {
  eks_cluster_name = var.eks_cluster_name != "" ? var.eks_cluster_name : var.name
}

# Create public subnet in availability zone ap-south-1a
resource "aws_subnet" "public-subnet-1a" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1a"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "Shared"
    "kubernetes.io/role/elb" = "1"
  }
}

# Create public subnet in availability zone ap-south-1b
resource "aws_subnet" "public-subnet-1b" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1b"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "Shared"
    "kubernetes.io/role/elb" = "1"
  }
}

# Create private subnet in availability zone ap-south-1a
resource "aws_subnet" "private-subnet-1a" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "private-subnet-1a"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "Shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Create private subnet in availability zone ap-south-1b
resource "aws_subnet" "private-subnet-1b" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "private-subnet-1b"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "Shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "igw"
  }
}

# Create route table for public subnet
resource "aws_route_table" "routeTablePub" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "routeTablePub"
  }
}

# Associate route tabe to public subnet 1a
resource "aws_route_table_association" "associate" {
  subnet_id      = "${aws_subnet.public-subnet-1a.id}"
  route_table_id = "${aws_route_table.routeTablePub.id}"
}

# Create Elastic IP
resource "aws_eip" "ip" {
  vpc      = true
  tags = {
    Name = "elasticIP"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = "${aws_eip.ip.id}"
  subnet_id     = "${aws_subnet.public-subnet-1a.id}"

  tags = {
    Name = "nat-gateway"
  }
}

# Create route table for private subnet
resource "aws_route_table" "routeTablePvt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat-gateway.id}"
  }

}

# Associate route table to private subnet
 resource "aws_route_table_association" "associate2" {
  subnet_id      = aws_subnet.private-subnet-1a.id
  route_table_id = aws_route_table.routeTablePvt.id
}
