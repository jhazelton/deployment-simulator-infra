# 1. Fetch the latest official Ubuntu 22.04 LTS AMD64 Image
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical's official AWS Owner ID
}

# 2. Build the Firewall (Security Group)
resource "aws_security_group" "simulator_sg" {
  name        = "simulator-sg"
  description = "Allow web, container, and SSH traffic"
  vpc_id      = aws_vpc.simulator_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "simulator-sg" }
}

# 3. Provision the Ubuntu EC2 Server Host (Inline user_data clears the API validation trap)
resource "aws_instance" "simulator_host" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" 

  subnet_id              = aws_subnet.simulator_public_subnet.id
  vpc_security_group_ids = [aws_security_group.simulator_sg.id]
  
  # Passes the startup initialization script as a safe, pre-validated native text block
  user_data = <<-EOT
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://docker.com | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://docker.com $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo mkdir -p /home/ubuntu/simulator/incoming
    sudo mkdir -p /home/ubuntu/simulator/deployed
    sudo mkdir -p /home/ubuntu/simulator/archived
    sudo mkdir -p /home/ubuntu/simulator/jim_logs
    sudo echo "schema_update.sql" > /home/ubuntu/simulator/deployment_files.txt
    sudo touch /home/ubuntu/simulator/incoming/schema_update.sql
    sudo chown -R ubuntu:ubuntu /home/ubuntu/simulator
    sudo chmod -R 777 /home/ubuntu/simulator
    sudo docker pull jhazelton55/deployment-simulator:latest
    sudo docker run -d -t --name python-deployment-simulator -v /home/ubuntu/simulator/deployment_files.txt:/app/deployment_files.txt -v /home/ubuntu/simulator/incoming:/app/incoming -v /home/ubuntu/simulator/deployed:/app/deployed -v /home/ubuntu/simulator/archived:/app/archived -v /home/ubuntu/simulator/jim_logs:/app/jim_logs YOUR_DOCKERHUB_USERNAME/deployment-simulator:latest
  EOT

  tags = { Name = "deployment-simulator-host" }
}

# 4. Output the public IP string
output "host_public_ip" {
  value       = aws_instance.simulator_host.public_ip
  description = "The public IP address of your new deployment simulator host"
}
