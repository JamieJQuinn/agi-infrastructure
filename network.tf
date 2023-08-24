resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/24"
  enable_dns_hostnames = true

  tags = {
    name = "MainVPC"
    project = "${var.project}"
  }
}

resource "aws_subnet" "agi" {
  availability_zone = "${var.availability_zone}"
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.0.0.0/25"
  map_public_ip_on_launch = true

  tags = {
    name = "Subnet"
    project = "${var.project}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    name = "PublicRoute"
    project = "${var.project}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    name = "PrivateRoute"
    project = "${var.project}"
  }
}

resource "aws_internet_gateway" "public" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "Internet gateway for the main VPC"
    project = "${var.project}"
  }
}

resource "aws_route" "public" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.public.id}"
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.agi.id}"
  route_table_id = "${aws_route_table.public.id}"
}
