# EC2 INSTANCES
resource "aws_instance" "ec2_a" {
  ami           = "ami-02457590d33d576c3"  # Amazon Linux 2 in us-west-1
  instance_type = "t2.micro"
  key_name      = "olusola"
  subnet_id     = aws_subnet.public_a.id
  security_groups = [aws_security_group.sga.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "Instance-SGA"
  }
}

resource "aws_instance" "ec2_b" {
  ami           = "ami-02457590d33d576c3"
  instance_type = "t2.micro"
  key_name      = "olusola"
  subnet_id     = aws_subnet.public_b.id
  security_groups = [aws_security_group.sgb.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "Instance-SGB"
  }
}
