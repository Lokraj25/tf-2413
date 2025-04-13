# vpc
resource "aws_vpc" "ecomm-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ecomm-vpc"
  }
}

# public subnet
resource "aws_subnet" "ecomm-web-sn" {
  vpc_id     = aws_vpc.ecomm-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone ="ap-northeast-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "ecomm-web-sn"
  }
}

# private subnet
resource "aws_subnet" "ecomm-data-sn" {
  vpc_id     = aws_vpc.ecomm-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone ="ap-northeast-1c"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "ecomm-database-sn"
  }
}


#internet gateway
resource "aws_internet_gateway" "ecomm-igw" {
  vpc_id = aws_vpc.ecomm-vpc.id

  tags = {
    Name = "ecomm-gateway"
  }
}


# public route
resource "aws_route_table" "ecomm-web-rt" {
  vpc_id = aws_vpc.ecomm-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecomm-igw.id
  }

  tags = {
    Name = "ecomm-route-table"
  }
}

#public route table association
resource "aws_route_table_association" "ecomm-web-et-association" {
  subnet_id      = aws_subnet.ecomm-web-sn.id
  route_table_id = aws_route_table.ecomm-web-rt.id
}



# private  route
resource "aws_route_table" "ecomm-data-rt" {
  vpc_id = aws_vpc.ecomm-vpc.id

  #route {
   # cidr_block = "0.0.0.0/0"
   # gateway_id = aws_internet_gateway.ecomm-igw.id
  #}

  tags = {
    Name = "ecomm-database-route-table"
 }
}

#private route table association
resource "aws_route_table_association" "ecomm-data-rt-association" {
  subnet_id      = aws_subnet.ecomm-data-sn.id
  route_table_id = aws_route_table.ecomm-web-rt.id
}




# public NACL
resource "aws_network_acl" "ecomm-web-nacl" {
  vpc_id = aws_vpc.ecomm-vpc.id

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
    Name = "ecomm-web-nacl"
  }
}


#public nacl association
resource "aws_network_acl_association" "ecomm-web-nacl-association" {
  network_acl_id = aws_network_acl.ecomm-web-nacl.id
  subnet_id      = aws_subnet.ecomm-web-sn.id
}


# private NACL
resource "aws_network_acl" "ecomm-data-nacl" {
  vpc_id = aws_vpc.ecomm-vpc.id

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
    Name = "ecomm-data-nacl"
  }
}


#private nacl association
resource "aws_network_acl_association" "ecomm-data-nacl-association" {
  network_acl_id = aws_network_acl.ecomm-data-nacl.id
  subnet_id      = aws_subnet.ecomm-data-sn.id
}

#public security group

resource "aws_security_group" "ecomm_web_sg" {
  name        = "ecomm_web_server_sg"
  description = "Allow web server traffic"
  vpc_id      = aws_vpc.ecomm-vpc.id
  tags = {
    Name = "ecomm_web_security_group"
  }
}

#ssh security groupp
resource "aws_vpc_security_group_ingress_rule" "ecomm_web_ssh" {
  security_group_id = aws_security_group.ecomm_web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#http security group
resource "aws_vpc_security_group_ingress_rule" "ecomm_http_ssh" {
  security_group_id = aws_security_group.ecomm_web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
