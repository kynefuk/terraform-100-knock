data "aws_ami" "ubuntu_20_04" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64*"]
  }
}

resource "aws_instance" "nginx" {
  ami                         = data.aws_ami.ubuntu_20_04.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.0.id
  vpc_security_group_ids      = [aws_security_group.public.id]
  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/bash
set -xe
timedatectl set-timezone Asia/Tokyo
apt update -y
apt install -y nginx
EOF

  tags = {
    "Name" = "${var.project}_nginx"
  }
}
