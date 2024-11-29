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

# k8s Controller
resource "aws_instance" "k8s_controller" {
  ami               = "ami-005fc0f236362e99f"  # rhel 9 AMI for us-east-1
  instance_type     = "t2.medium"
  key_name          = "vockey"
  security_groups   = [aws_security_group.allow_ssh.name]
  tags = {
    Name = "k8s-controller"
  }
}

 # k8s Workers
resource "aws_instance" "k8s_workers" {
  count             = 2
  ami               = "ami-005fc0f236362e99f"  # CentOS 7 AMI for us-east-1
  instance_type     = "t2.medium"
  key_name          = "vockey"
  security_groups   = [aws_security_group.allow_ssh.name]
  tags = {
    Name = "k8s-worker-${count.index + 1}"
  }
}