provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "deployer_key" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub") # Usa tu clave pública
}

resource "aws_security_group" "deployer_sg" {
  name_prefix = "deployer-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Acceso SSH desde cualquier lugar (ajusta según tu caso)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # HTTP (puerto 80)
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Grafana (puerto 3000)
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Prometheus (puerto 9090)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "deployer_ec2" {
  ami           = "ami-0a91cd140a1fc148a" # Amazon Linux 2 AMI (actualízalo según tu región)
  instance_type = "t3.micro"

  key_name           = aws_key_pair.deployer_key.key_name
  security_groups    = [aws_security_group.deployer_sg.name]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y jq docker git
    amazon-linux-extras enable docker
    systemctl start docker
    systemctl enable docker
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    # Clonar repositorio
    git clone https://github.com/user/geomap-builder.git /home/ec2-user/geomap-builder
    cd /home/ec2-user/geomap-builder
    chmod +x deployer.sh
    . ./deployer.sh
  EOF

  tags = {
    Name = "Deployer-EC2"
  }
}

output "public_ip" {
  value = aws_instance.deployer_ec2.public_ip
  description = "Public IP of the deployed EC2 instance"
}