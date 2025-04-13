# EC2 server

resource "aws_instance" "ecomm_web_server" {
  ami           = "ami-0f415cc2783de6675"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.ecomm-web-sn.id
  key_name      = "aws830"
  vpc_security_group_ids = [aws_security_group.ecomm_web_sg.id]
  user_data = file("ecomm.sh")


  tags = {
    Name = "ecomm_web_server"
  }
}