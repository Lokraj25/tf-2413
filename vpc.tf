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
resource "aws_route_table" "ibm-web-rt" {
  vpc_id = aws_vpc.ibm-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ibm-igw.id
  }

  tags = {
    Name = "ibm-route-table"
  }
}

#public route table association
resource "aws_route_table_association" "ibm-web-et-association" {
  subnet_id      = aws_subnet.ibm-web-sn.id
  route_table_id = aws_route_table.ibm-web-rt.id
}



# private  route
resource "aws_route_table" "ibm-data-rt" {
  vpc_id = aws_vpc.ibm-vpc.id

  #route {
   # cidr_block = "0.0.0.0/0"
   # gateway_id = aws_internet_gateway.ibm-igw.id
  #}

  tags = {
    Name = "ibm-database-route-table1"
 }
}

#private route table association
resource "aws_route_table_association" "ibm-data-rt-association" {
  subnet_id      = aws_subnet.ibm-data-sn.id
  route_table_id = aws_route_table.ibm-web-rt.id
}




# public NACL
resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.ibm-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "ibm-web-nacl"
  }
}


#public nacl association
resource "aws_network_acl_association" "ibm-web-nacl-association" {
  network_acl_id = aws_network_acl.ibm-web-nacl.id
  subnet_id      = aws_subnet.ibm-web-sn.id
}