provider "aws" {
  region = "eu-west-1"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_iam_role" "web_app" {
  name = "web-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "web_app_ssm" {
  name = "web-app-ssm-read"
  role = aws_iam_role.web_app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameter"]
      Resource = "arn:aws:ssm:eu-west-1:*:parameter/web-app/api-token"
    }]
  })
}

resource "aws_iam_instance_profile" "web_app" {
  name = "web-app-profile"
  role = aws_iam_role.web_app.name
}

resource "aws_instance" "web_app" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = "t3.micro"  # Free tier eligible
  iam_instance_profile = aws_iam_instance_profile.web_app.name

  vpc_security_group_ids = [aws_security_group.web_app.id]

  user_data = <<-EOF
    #!/bin/bash
    set -e
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    for i in {1..10}; do
      API_TOKEN=$(aws ssm get-parameter --name /web-app/api-token --with-decryption --query Parameter.Value --output text --region eu-west-1) && break
      sleep 5
    done
    docker run -d --restart always -p 80:8888 -e PORT=8888 -e API_TOKEN="$API_TOKEN" chagan1985/web-app:latest
  EOF

  tags = {
    Name = "web-app"
  }
}

resource "aws_security_group" "web_app" {
  name = "web-app-sg"

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

output "app_url" {
  value = "http://${aws_instance.web_app.public_ip}:80"
}
