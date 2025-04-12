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


# public route
resource "aws_route_table1" "ibm-data-rt" {
  vpc_id = aws_vpc.ibm-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ibm-igw.id
  }

  tags = {
    Name = "ibm-route-table1"
  }
}

#public route table association
resource "aws_route_table_association1" "ibm-web-et-association" {
  subnet_id      = aws_subnet.ibm-web-sn.id
  route_table_id = aws_route_table.ibm-web-rt.id
}



# private  route
resource "aws_route_table" "ibm-data-rt" {
  vpc_id = aws_vpc.ibm-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ibm-igw.id
  }

  tags = {
    Name = "ibm-database-route-table"
  }
}

#public route table association
resource "aws_route_table_association" "ibm-data-et-association" {
  subnet_id      = aws_subnet.ibm-data-sn.id
  route_table_id = aws_route_table.ibm-web-rt.id
}