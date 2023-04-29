provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "my-terraform-statebackendbucket" {
    bucket = "my-terraform-statebackendbucket"
}

//versioning is enabled by default 
resource "aws_s3_bucket_versioning" "my-terraform-statebackendbucket" {
    bucket = "my-terraform-statebackendbucket"
    //enabled = true
    
    versioning_configuration {

    status = "Enabled"

    }
}

//


data "aws_availability_zones" "available" {}

resource "aws_vpc" "my-terraform-vpc" {
    cidr_block = "172.31.0.0/16"
    tags = {
        Name = "my-terraform-vpc"
    }
}

resource "aws_subnet" "subnet1" {
    vpc_id  = aws_vpc.my-terraform-vpc.id
    cidr_block = "172.31.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "subnet1"
    }
}

resource "aws_subnet" "subnet2" {
    vpc_id  = aws_vpc.my-terraform-vpc.id
    cidr_block = "172.31.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "subnet2"
    }
}


resource "aws_security_group" "autoscaling" {
    name_prefix = "autiscaling"
    vpc_id = aws_vpc.my-terraform-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }


    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

//Autoscaling Group configuration

resource "aws_launch_configuration" "autoscaling" {
    name_prefix = "autoscaling"
    image_id = "ami-0d8f6eb4f641ef691"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.autoscaling.id]
}

resource "aws_autoscaling_group" "autoscaling" {
    name_prefix = "autoscaling"
    launch_configuration = aws_launch_configuration.autoscaling.id
    max_size = 5
    min_size = 2
    vpc_zone_identifier = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}

