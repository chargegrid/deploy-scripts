provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "aws_ami" "aws_linux_ami" {
  most_recent      = true

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  owners     = ["amazon"]
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "chargegrid_demo"
  description = "Used for the ChargeGrid demo"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # all access from the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "demo" {
  ami           = "${data.aws_ami.aws_linux_ami.id}"
  instance_type = "t2.xlarge"
  key_name 		= "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  subnet_id = "${aws_subnet.default.id}"

  connection {
    user        = "ec2-user"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "local-exec" {
    command = "./prepare-install-scripts.sh"
  }

  provisioner "file" {
    source      = "temp-demo-install.sh"
    destination = "install.sh"
  }

  provisioner "file" {
    source      = "temp-docker-compose-demo.yml"
    destination = "docker-compose.yml"
  }

  provisioner "file" {
    source      = "create-exchanges.sh"
    destination = "create-exchanges.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x install.sh",
      "chmod +x create-exchanges.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "./install.sh"
    ]
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.demo.id}"
  allocation_id = "${var.elastic_ip_id}"
}