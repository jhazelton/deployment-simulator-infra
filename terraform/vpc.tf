# Create the base Network Envelope
resource "aws_vpc" "simulator_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "simulator-vpc" }
}

# Attach an Internet Gateway directly to the edge
resource "aws_internet_gateway" "simulator_igw" {
  vpc_id = aws_vpc.simulator_vpc.id
  tags   = { Name = "simulator-igw" }
}

# Define a clean Internet-Facing Subnet
resource "aws_subnet" "simulator_public_subnet" {
  vpc_id                  = aws_vpc.simulator_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true # Guaranteed public routing out of the box!

  tags = { Name = "simulator-public-subnet" }
}

# Bind the Routing Table directly out to the Gateway
resource "aws_route_table" "simulator_rt" {
  vpc_id = aws_vpc.simulator_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.simulator_igw.id
  }

  tags = { Name = "simulator-public-rt" }
}

# Hook the Subnet and Route Table together
resource "aws_route_table_association" "simulator_rta" {
  subnet_id      = aws_subnet.simulator_public_subnet.id
  route_table_id = aws_route_table.simulator_rt.id
}
