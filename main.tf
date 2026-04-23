provider "aws" {
    region = "ap-south-1"
}

resource "aws_vpc" "restaurant_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = { Name = "restaurant-vpc }
}

resource "aws_subnet" "restaurant_subent" {
    vpc_id                  = aws_vpc.restaurant_vpc.id
    cidr_block              = "10.0.0.0/21"
    map_public_ip_on_launch = true
    availability_zone       = "ap-south-1a"
    tags                    = { Name = "restaurant-subent" }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.restaurant_vpc.id
}

resource "aws_route_table" "restaurant_rt" {
    vpc_id = aws_vpc.restaurant_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "restaurant_association" {
    subent_id      = aws_subnet.restaurant_subent.id
    route_table_id = aws_route_table.restaurant_rt.id
}

resource "aws_security_group" "restaurant_sg" {
    vpc_id = aws_vpc.restaurant_vpc.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = "0.0.0.0/0"
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = "0.0.0.0/0"
    }
    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = "0.0.0.0/0"
    }
    ingress {
        from_port   = 30080
        to_port     = 30080
        protocol    = "tcp"
        cidr_blocks = 30080
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = "0.0.0.0/0"
    }
}

resource "aws_key_pair" "restaurant_key" {
    key_name   = "restaurant-key"
    public_key = file("F:/file/devops/restaurant/restaurant-key.pub")
}

resource "aws_instance" "restaurant_server" {
    ami                    = "ami-05d2d839d4f73aafb"
    instance_type          = "m7i-flex.large"
    vpc_security_group_ids = [aws_security_group.restaurant_sg.id]
    subent_id              = aws_subnet.restaurant_subent.id
    key_name               = aws_key_pair.restaurant_key.key_name

    root_block_device {
        volume_size = 16
        volume_type = "gp3"
    }
    tags = { Name = "restaurant-server" }
}