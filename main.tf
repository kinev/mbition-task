resource "aws_vpc" "client_vpc" {
  cidr_block = var.client_vpc_cidr_block

  tags = {
    Name = "${var.client}_${terraform.workspace}_vpc"
    Client = var.client
  }
}

resource "aws_subnet" "client_public_subnet" {
  vpc_id = aws_vpc.client_vpc.id
  cidr_block = var.client_public_subnet
  availability_zone = var.availability_zone

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.client}_${terraform.workspace}_public_subnet"
    Client  = var.client
  }
}

resource "aws_instance" "client_demo_instance" {
  ami = var.client_demo_instance_ami
  instance_type = var.client_demo_instance_type
  subnet_id = aws_subnet.client_public_subnet.id

  key_name = "test vpc ec2"

  vpc_security_group_ids = [aws_security_group.client_ssh_sg.id]

  user_data = "${file("./init.sh")}"

  tags = {
    Name = "${var.client}_${terraform.workspace}_demo_instance"
    Client  = var.client
  }
}

resource "aws_ebs_volume" "client_demo_instance_ebs" {
  availability_zone = var.availability_zone
  size = var.client_demo_instance_ebs_size

  tags = {
    Name = "${var.client}_${terraform.workspace}_demo_instance_ebs"
    Client  = var.client
  }
}

resource "aws_internet_gateway" "client_vpc_igw" {
  vpc_id = aws_vpc.client_vpc.id

  tags = {
    Name = "${var.client}_${terraform.workspace}_vpc_igw"
    Client = var.client
  }
}

resource "aws_route_table" "client_igw_rt" {
  vpc_id = aws_vpc.client_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.client_vpc_igw.id
  }

  tags = {
    Name = "${var.client}_${terraform.workspace}_igw_rt"
    Client = var.client
  }
}

resource "aws_security_group" "client_ssh_sg" {
  name        = "${var.client}_${terraform.workspace}_ssh_sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.client_vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_subnet.client_public_subnet.cidr_block]
  }

  ingress {
    description      = "SSH from Plamen"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["84.238.195.101/32"]
  }

  ingress {
    description      = "HTTP from Plamen"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["84.238.195.101/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.client}_ssh_http_sg"
    Client = var.client
  }
}

resource "aws_eip" "client_demo_instance_eip" {
  instance = aws_instance.client_demo_instance.id
  domain   = "vpc"

  tags = {
    Name = "${var.client}_${terraform.workspace}_elastic_ip"
    Client = var.client
  }
}

resource "aws_volume_attachment" "client_demo_instance_ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.client_demo_instance_ebs.id
  instance_id = aws_instance.client_demo_instance.id
  force_detach = true
}

resource "aws_route_table_association" "client_public_subnet_igw" {
  subnet_id      = aws_subnet.client_public_subnet.id
  route_table_id = aws_route_table.client_igw_rt.id
}

output "client_demo_instance_public_ip" {
  value = aws_eip.client_demo_instance_eip.public_ip 
}
