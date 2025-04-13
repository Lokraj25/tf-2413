# EC2 server

resource "aws_instance" "ibm-web-server" {
  ami           = ami-0f415cc2783de6675
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.ibm-web-sn.id
  key_name      = "aws830"
  vpc_security_group_ids = aws_security_group.ibm_web_sg.id



  tags = {
    Name = "ibm_web_server"
  }
}