# vpc
resource "aws_vpc" "ibm-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ibm"
  }
}

# public subnet
resource "aws_subnet" "ibm-web-sn" {
  vpc_id     = aws_vpc.ibm-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone ="ap-northeast-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "ibm-web-sn"
  }
}

# private subnet
resource "aws_subnet" "ibm-data-sn" {
  vpc_id     = aws_vpc.ibm-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone ="ap-northeast-1c"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "ibm-database-sn"
  }
}


#internet gateway
resource "aws_internet_gateway" "ibm-igw" {
  vpc_id = aws_vpc.ibm-vpc.id

  tags = {
    Name = "ibm-gateway"
  }
}