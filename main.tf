############ providers ##############
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
backend "s3" {
    bucket = "terraform-bucket"
    key    = "tfstate/terraform.tfstate"
    region = "eu-west-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}



####### vpc created #######

resource "aws_vpc" "ahmad-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ahmad-vpc"
  }
}

variable "subnet-var" {

    description = "hello"
    type = map(string)
    default = {
	"ap-south-1a" = "10.0.1.0/24" 
	"ap-south-1b" = "10.0.2.0/24" 
	"ap-south-1c" = "10.0.3.0/24"

}
	
}

########## subnet created #########

resource "aws_subnet" "bjs-subnet" {
  for_each = var.subnet-var
  vpc_id     = aws_vpc.ahmad-vpc.id
  cidr_block = each.value
  availability_zone = each.key
  
}

########### Internet gateway ##############
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ahmad-vpc.id

  tags = {
    Name = "ahmad-vpc-igw"
  }
}

###############  Routes ######################

resource "aws_route_table" "ahmad-routes" {
  vpc_id = aws_vpc.ahmad-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "ahmad-routes"
  }
}


############ security group ###############

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.ahmad-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
