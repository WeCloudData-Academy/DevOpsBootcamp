cidr_blocks = "10.0.0.0/16"
subnet_cidr_block = "10.0.10.0/24"
avail_zone = "us-east-1a"
env_prefix = "DevOpsBootcamp"
my_ip = "0.0.0.0/0"
instance_type = "t2.micro"
public_key_location = "~/.ssh/id_rsa.pub"
image_name = "amzn2-ami-hvm-*-x86_64-gp2"
instance_name = [
    "DevOpsBootcampDev",
    "DevOpsBootcampProd",
    "DevOpsBootcampTest"
]