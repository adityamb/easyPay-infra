/* Start with adding the local variables, which will be used throughout the script ami-id of the instance */







locals {



  ami_id = "ami-09e67e426f25ce0d7"



  vpc_id = "vpc-0b93718c3ef8e659c"



  ssh_user = "ubuntu"



  key_name = "easykey"     # the name should match with the name on cloud



  instance_count = 3



  private_key_path = "/home/adityabhatambgm/infra-easyPay/easykey.pem" 



}







/* Declare the provider and other required information linked with it, access key, secret key and token as per AWS 



(Any cloud provider you are using) */







provider "aws" {



  region     = "us-east-1"



  access_key = "ASIA25AYTKZSFJN6C6N7"



  secret_key = "AZRBvPFeZG84FmxFn2rY4Ex2DSl+DxwHWykF9ZgM"



  token = "FwoGZXIvYXdzEOP//////////wEaDOeLZiE/NUqTDnF5siK6AWfREIoJB8RYn14auqf3xTPW/Ratm8Hl/xt45JAewbazvqIJ3PVDmKtgyzv2x9I+LP4v6Iy93eQEOWo/+N2mWhZh8SojHXikS/zSgnqlCWu3U2zkANwaE3bK3VgMmdWSQiL3I+stFNpWLY8VBfVzG20fdkuvceluBIG5VMFpDslZdQi9WSrfYcxCZnJUQHRcdng/b/hj4NVzuM5Fc1QGDuwPjbkxPMQzt9lrVQ7SW7QBwTeKF07TI5c7xCiJgvmfBjItyuAGXa9fqAKfcsEoOd8a3l6gIWZ+OQCm8RIbh0vb6hqw4yKbwlpYaGIZPhbR"



}







/* [4.1] Creating a security group with the name of k8saccess and setting ingress egress security rules, it will automatically use the vac id from variables declared in local. */







resource "aws_security_group" "k8saccess" {



  name   = "cap_access"



  vpc_id = local.vpc_id



    



  ingress {



    from_port   = 22



    to_port     = 22



    protocol    = "tcp"



    cidr_blocks = ["0.0.0.0/0"]



  }







  ingress {



    from_port   = 0



    to_port     = 0



    protocol    = "-1"



    cidr_blocks = ["0.0.0.0/0"]



  }







  egress {



    from_port   = 0



    to_port     = 0



    protocol    = "-1"



    cidr_blocks = ["0.0.0.0/0"]



  }



}



# Resource creation using local variables - ami, security group and key. 







resource "aws_instance" "web" {



  count = local.instance_count



  ami = local.ami_id



  instance_type = "t2.medium"



  associate_public_ip_address = "true"



  vpc_security_group_ids =[aws_security_group.k8saccess.id]



  key_name = local.key_name







  tags = {



    Name = "easy-ec2"



  }







  /* Setting up connection as we want to use ssh for Ansible configurations to run. Again using local variables for host ip, user name, and security key */







  connection {



    type = "ssh"



    host = self.public_ip



    user = local.ssh_user



    private_key = file(local.private_key_path)



    timeout = "2m"



  }







  provisioner "local-exec" {



    command = "echo ${self.public_ip} >> myhosts"



  }



# Just to confirm whether our remote access is working







  provisioner "remote-exec" {



    inline = [



      "hostname"



    ]



  }







}

