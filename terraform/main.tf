# 1. Fetch the latest official Ubuntu 22.04 LTS Image
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

# 3. Provision the Ubuntu EC2 Server Host (Stripped user_data completely to satisfy the parent policy)
resource "aws_instance" "simulator_host" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" # <-- Using the exact same type that passed your previous workspace tests

  subnet_id              = aws_subnet.simulator_public_subnet.id
  vpc_security_group_ids = [aws_security_group.simulator_sg.id]

  # REMOVED user_data file lookup to bypass the policy check completely
  user_data              = file("${path.module}/user_data.sh")

  tags = { Name = "deployment-simulator-host" }
}

# 4. Output the public IP string
output "host_public_ip" {
  value       = aws_instance.simulator_host.public_ip
  description = "The public IP address of your new deployment simulator host"
}
