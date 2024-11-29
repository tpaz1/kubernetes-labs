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
    cidr_blocks = ["0.0.0.0/0"]  # Allows MySQL from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"            # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]   # Allows outbound to the internet
  }
}

resource "aws_instance" "k8s-minikube" {
  ami               = "ami-005fc0f236362e99f"  # Ubuntu AMI ID (replace with actual Ubuntu AMI ID for us-east-1)
  instance_type     = "t2.medium"
  key_name          = "vockey"
  security_groups   = [aws_security_group.allow_ssh.name]

  user_data = <<-EOF
              #!/bin/bash
              # Update system and install dependencies
              sudo apt update -y
              sudo apt install -y curl wget apt-transport-https conntrack docker.io

              # Start Docker service
              sudo systemctl enable docker
              sudo systemctl start docker

              # Add current user to Docker group
              sudo usermod -aG docker ubuntu
              newgrp docker

              # Install kubectl
              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              sudo install kubectl /usr/local/bin/kubectl

              # Install Minikube
              curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
              sudo install minikube-linux-amd64 /usr/local/bin/minikube

              # Start Minikube with Docker driver
              minikube start --driver=docker

              # Output the Minikube status
              minikube status
              EOF

  tags = {
    Name = "k8s-minikube"
  }
}
