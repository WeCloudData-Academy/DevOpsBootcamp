provider "aws" {
    # location of your credential
    shared_credentials_files = ["/Users/daweizhang/.aws/config"]
    # name of your profile
    profile = "beamdata-dawei"
    region = "us-east-1"
}

variable cidr_blocks {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip{}
variable instance_type{}
variable public_key_location{}
variable image_name{}
variable instance_name{type = set(string)}

# create a new vpc
resource "aws_vpc" "DevOpsBootcamp-vpc" {
    cidr_block = var.cidr_blocks
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

# create a new subnet
resource "aws_subnet" "DevOpsBootcamp-subnet-1" {
    vpc_id = aws_vpc.DevOpsBootcamp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

# create a new route table
resource "aws_route_table" "DevOpsBootcamp-route-table" {
    vpc_id = aws_vpc.DevOpsBootcamp-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.DevOpsBootcamp-igw.id
    }

    tags = {
        Name: "${var.env_prefix}-rtb"
    }
}

# create a internet gateway for the VPC
resource "aws_internet_gateway" "DevOpsBootcamp-igw" {
    vpc_id = aws_vpc.DevOpsBootcamp-vpc.id
    tags = {
        Name: "${var.env_prefix}-rtb"
    }
}

# associate the aws route table with the subnet that just got created
resource "aws_route_table_association" "DevOpsBootcamp-rtb-subnet" {
    subnet_id = aws_subnet.DevOpsBootcamp-subnet-1.id
    route_table_id = aws_route_table.DevOpsBootcamp-route-table.id
}

# configure the security group
# open port 22 and 8080 as inbound rule for ssh and web app
# open port for all as outbound rule for the instance to have access to internet
resource "aws_security_group" "DevOpsBootcamp-sg" {
    name = "DevOpsBootcamp-sg"
    vpc_id = aws_vpc.DevOpsBootcamp-vpc.id

    ingress {
        from_port = 22
        to_port = 22 # a range, from 22 to 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip] # list of IP address allowed to access the server
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }
    tags = {
        Name: "${var.env_prefix}-sg"
    }
}

# get the image you expected
data "aws_ami" "latest-amazon-linux-image"{
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = [var.image_name]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}
# output the image id
output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}

resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = "${file(var.public_key_location)}"
}
resource "aws_instance" "DevOpsBootcamp-server"{
    ami = data.aws_ami.latest-amazon-linux-image.id
    # create the instance
    instance_type = var.instance_type
    subnet_id = aws_subnet.DevOpsBootcamp-subnet-1.id
    vpc_security_group_ids = [aws_security_group.DevOpsBootcamp-sg.id]
    availability_zone = var.avail_zone
    # asscociate public ip to the server so that we could ssh to it
    associate_public_ip_address = true 
    # use the key pair to ssh to the server
    key_name = aws_key_pair.ssh-key.key_name 

    # run nginx docker container in the ec2-user
    # user_data = file("entry-script.sh")
    tags = {
        Name: each.value
    }
    for_each = var.instance_name

}

output "ec2_public_ips" {
    value = {
        for key, server in aws_instance.DevOpsBootcamp-server :  key => server.public_ip
    }
}

# save the public ips of the servers to a file
resource "local_file" "public_ips" {
    filename = "../Ansible lab/hosts"
    depends_on = [
      aws_instance.DevOpsBootcamp-server
    ]
    # convert map to string
    content  = format("%s%s%s%s", 
                    join( "\n", [for key, server in aws_instance.DevOpsBootcamp-server :  "${key} ansible_host=${server.public_ip}"]),
                    "\n\n[DevOpsBootcamp-servers]\n",
                    join("\n",[for key, server in aws_instance.DevOpsBootcamp-server :  "${key}"]),
                    "\n\n[DevOpsBootcamp-servers:vars]\nansible_user=ec2-user\nansible_ssh_private_key_file=~/.ssh/id_rsa")
}
