resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "${var.project}_vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.project}_gw"
  }
}

resource "aws_eip" "for_ngw" {
  vpc = true
  tags = {
    "Name" = "${var.project}_eip"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.for_ngw.id
  subnet_id     = aws_subnet.public.0.id
  tags = {
    "Name" = "${var.project}_ngw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  count             = length(var.az)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, "8", (count.index + 0) * 2)
  availability_zone = var.az[count.index]
  tags = {
    "Name" = "${var.project}_public_${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.project}_public"
  }
}

resource "aws_route" "from_public_to_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
  depends_on = [
    aws_route_table.public
  ]
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "public" {
  name   = "${var.project}_sg_public_subnet"
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.project}_public"
  }
}

resource "aws_security_group_rule" "public_tcp_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_tcp_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "health_check" {
  type              = "egress"
  from_port         = 0
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = tolist(aws_subnet.private.*.cidr_block)
  security_group_id = aws_security_group.public.id
}

# Private Subnet
resource "aws_subnet" "private" {
  count             = length(var.az)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, "8", (count.index + 1) * 3)
  availability_zone = var.az[count.index]
  tags = {
    "Name" = "${var.project}_private_${count.index}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.project}_private"
  }
}

resource "aws_route" "from_private_to_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.ngw.id
  depends_on = [
    aws_route_table.private
  ]
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "private" {
  name   = "${var.project}_sg_private_subnet"
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.project}_private"
  }
}

resource "aws_security_group_rule" "private_tcp_ingress" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public.id
  security_group_id        = aws_security_group.private.id
}

# resource "aws_security_group_rule" "private_ssh_ingress" {
#   type              = "ingress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.private.id
# }

resource "aws_security_group_rule" "private_tcp_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private.id
}
