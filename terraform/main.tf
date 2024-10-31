# main.tf
provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows SSH from anywhere
  }

   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows HTTP from anywhere
  }
   ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows HTTP from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"            # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]   # Allows outbound to the internet
  }
}

# Ansible Controller
resource "aws_instance" "ansible_controller" {
  ami               = "ami-0583d8c7a9c35822c"  # rhel 9 AMI for us-east-1
  instance_type     = "t2.medium"
  key_name          = "vockey"
  security_groups   = [aws_security_group.allow_ssh.name]

  user_data = <<-EOF
            #!/bin/bash
            sudo dnf install ansible-core -y || { echo 'Ansible installation failed' > /tmp/ansible_install_error.log; exit 1; }
            sudo dnf install -y git || { echo 'Git installation failed' > /tmp/git_install_error.log; exit 1; }
            # Clone the public repository
            git clone https://github.com/tpaz1/ansible-labs.git /home/ec2-user/ansible-labs || { echo 'Git clone failed' > /tmp/git_clone_error.log; exit 1; }
            sudo chown -R ec2-user:ec2-user /home/ec2-user/ansible-labs
            EOF

  tags = {
    Name = "ansible-controller"
  }
}

# # Ansible Workers
# resource "aws_instance" "ansible_workers" {
#   count             = 2
#   ami               = "ami-0583d8c7a9c35822c"  # CentOS 7 AMI for us-east-1
#   instance_type     = "t2.small"
#   key_name          = "vockey"
#   security_groups   = [aws_security_group.allow_ssh.name]

#   tags = {
#     Name = "ansible-worker-${count.index + 1}"
#   }
# }