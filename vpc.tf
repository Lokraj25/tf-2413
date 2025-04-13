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
    Name = "ibm-database-route-table"
 }
}

#private route table association
resource "aws_route_table_association" "ibm-data-rt-association" {
  subnet_id      = aws_subnet.ibm-data-sn.id
  route_table_id = aws_route_table.ibm-web-rt.id
}




# public NACL
resource "aws_network_acl" "ibm-web-nacl" {
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


# private NACL
resource "aws_network_acl" "ibm-data-nacl" {
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
    Name = "ibm-data-nacl"
  }
}


#private nacl association
resource "aws_network_acl_association" "ibm-data-nacl-association" {
  network_acl_id = aws_network_acl.ibm-data-nacl.id
  subnet_id      = aws_subnet.ibm-data-sn.id
}

#public security group

resource "aws_security_group" "ibm_web_sg" {
  name        = "ibm_web_server_sg"
  description = "Allow web server traffic"
  vpc_id      = aws_vpc.ibm_vpc.id

  tags = {
    Name = "ibm_web_security_group"
  }
}

#ssh security groupp
resource "aws_vpc_security_group_ingress_rule" "ibm_web_ssh" {
  security_group_id = aws_security_group.ibm_web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#http security group
resource "aws_vpc_security_group_ingress_rule" "ibm_http_ssh" {
  security_group_id = aws_security_group.ibm_web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
