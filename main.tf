#hey

# resource "aws_security_group" "sg" {
#   name        = "allow_all_traffic"
#   description = "Allow All inbound traffic"

#   ingress {
#     description      = "All Traffic"
#     cidr_blocks      = ["0.0.0.0/0", ]
#     from_port        = 0
#     ipv6_cidr_blocks = []
#     prefix_list_ids  = []
#     protocol         = "-1"
#     security_groups  = []
#     self             = false
#     to_port          = 0
#   }

#   egress {
#     cidr_blocks      = ["0.0.0.0/0", ]
#     description      = ""
#     from_port        = 22
#     ipv6_cidr_blocks = []
#     prefix_list_ids  = []
#     protocol         = "tcp"
#     security_groups  = []
#     self             = false
#     to_port          = 22
#   }

#   tags = {
#     Name = "all_traffic"
#   }
# }






#####  AWS Instance #####


#####################################################################################################################




resource "aws_security_group" "sg" {
  name = "nginx_access"
  # vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RSA key of size 4096 bits
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = tls_private_key.rsa.public_key_openssh
}


resource "local_file" "TF-key" {
  content         = tls_private_key.rsa.private_key_pem
  file_permission = "0400"
  filename        = "tfkey.txt"
}

locals {
  ssh_user         = "ubuntu"
  key_name         = "deployer-key"
  private_key_path = "~/014/tfkey.txt"

}

# output "nginx_ip_pem" {
#   value = locals.private_key_path
# }

resource "aws_instance" "nginx" {
  count         = 3
  ami           = "ami-005de95e8ff495156"
  instance_type = "t2.micro"
  #count         = 3
  # associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = aws_key_pair.deployer.key_name
  # key_name                    = local.key_name
#  tags = {
#    Name = "my-machine-${count.index}"
#  }

#  provisioner "remote-exec" {
##    inline = ["echo 'Wait until SSH is ready'"]

#    connection {
#      type        = "ssh"
#      user        = local.ssh_user
#      private_key = file(local.private_key_path)
#      host        = aws_instance.nginx[count.index].public_ip
#    }
#  }

#  provisioner "local-exec" {
#    command = "ansible-playbook  -i ${aws_instance.nginx[count.index].public_ip}, --private-key ${local.private_key_path} nginx.yaml"
#  }
}

#output "nginx_ip" {
#  value = aws_instance.nginx[count.index].public_ip
#}



# resource "aws_instance" "ec2" {
#   ami                    = "ami-005de95e8ff495156"
#   instance_type          = "t2.micro"
#   key_name               = aws_key_pair.deployer.key_name
#   vpc_security_group_ids = [aws_security_group.sg.id]

#   tags = {
#     Name = "HelloWorld"
#   }
# }

# resource "aws_eip" "eip" {
#   instance = aws_instance.ec2.id
#   vpc      = true
# }

# output "public_ip" {
#   value = aws_instance.ec2.public_ip
# }
