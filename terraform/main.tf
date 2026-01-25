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
                                                                                                                                                                                                                                              
resource "aws_instance" "web_app" {                                                                                                                                                                                                         
  ami           = data.aws_ami.amazon_linux.id                                                                                                                                                                                              
  instance_type = "t3.micro"  # Free tier eligible                                                                                                                                                                                          
                                                                                                                                                                                                                                            
  vpc_security_group_ids = [aws_security_group.web_app.id]                                                                                                                                                                                  
                                                                                                                                                                                                                                            
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    docker run -d --restart always -p 80:8888 -e PORT=8888 chagan1985/web-app:latest
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
