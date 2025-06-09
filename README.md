

![Aws architecture Diagram](https://github.com/user-attachments/assets/19e101d9-28a0-4731-b97b-80b519b6c059)



# 🛡️ AWS VPC Security Group & NACL Challenge Project

This project demonstrates how to build and secure an AWS network using Terraform. You will:
- Create a custom VPC
- Launch EC2 instances
- Configure Security Groups (SGs) and Network ACLs (NACLs)
- Test network connectivity using `ping`, `curl`, and browser

## 🚀 Features
- Custom VPC with two public subnets
- Internet Gateway and routing
- Security Groups with specific traffic rules
- EC2 instances with Apache installed via user data
- Inbound/Outbound ICMP and HTTP testing
- Restricting traffic via Security Groups and NACLs

---

## 📁 Project Structure
```bash
.
├── provider.tf   # Terraform main configuration
├── vpc.tf        # Input variables
├── sg.tf         # Apache setup script for EC2
└── README.md     # This file
```

---

## 🔧 Prerequisites
- AWS CLI configured
- Terraform installed
- A valid AWS Key Pair created in your region

<img width="960" alt="2025-06-09 (5)" src="https://github.com/user-attachments/assets/3b781b78-d9dc-434e-a1f4-1a7ad45d348e" />



---

## 📜 Terraform Code

### main.tf
```hcl
provider "aws" {
  region = us-east-1
}

# VPC DEFINITION
resource "aws_vpc" "project" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "lab1-custom"
  }
}

# PUBLIC SUBNETS
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.project.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.project.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-b"
  }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.project.id

  tags = {
    Name = "lab1-igw"
  }
}

# ROUTE TABLE AND ROUTE
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.project.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "lab1-public-rt"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "sgb" {
  name        = "SGB"
  description = "Security Group B"
  vpc_id      = aws_vpc.project.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port                = -1
    to_port                  = -1
    protocol                 = "icmp"
    security_groups          = [aws_security_group.sga.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SGB"
  }
}

# EC2 INSTANCES
resource "aws_instance" "ec2_a" {
  ami           = "ami-02457590d33d576c3"  # Amazon Linux 2 in us-west-1
  instance_type = "t2.micro"
  key_name      = "olusola"
  subnet_id     = aws_subnet.public_a.id
  security_groups = [aws_security_group.sga.id]

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
  security_groups = [aws_security_group.sga.id]

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

```

<img width="960" alt="2025-06-09 (6)" src="https://github.com/user-attachments/assets/aaba5526-6bc0-4be0-bf91-c6245b965a05" />


### userdata.sh
```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
<img width="960" alt="2025-06-09" src="https://github.com/user-attachments/assets/9fbc92dc-0873-4bda-82c7-327f7cf98fd4" />
```

---

![Uploading 2025-06-09.png…]()


---

## ✅ Final Tests
- ✅ Ping between EC2-A and EC2-B (ICMP)
- ✅ Curl Apache from SGB to SGA
- ✅ HTTP restricted to home IP
- ✅ NACL blocks access
- ✅ HTTP only allowed from SGA to SGB

---
<img width="960" alt="2025-06-09 (11)" src="https://github.com/user-attachments/assets/b07f41b3-1237-4b6b-aaf9-7a6834a74141" />



## 📚 License
This project is open for educational purposes. Feel free to reuse or improve it!
