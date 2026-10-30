#!/bin/bash
# Wait 30 seconds for native Ubuntu cloud-init tasks to settle down
sleep 30

# 1. Prevent interactive prompts during installation
export DEBIAN_FRONTEND=noninteractive

# 2. Update packages and install Docker natively
sudo apt-get update -y
sudo apt-get install -y docker.io

# Start and enable the Docker service
sudo systemctl start docker
sudo systemctl enable docker

# 3. Create host storage directories matching your Python script definitions
sudo mkdir -p /home/ubuntu/simulator/deployed
sudo mkdir -p /home/ubuntu/simulator/archived
sudo mkdir -p /home/ubuntu/simulator/jim_logs

# 4. Fix user permissions so the Docker runtime engine can alter files on the host
sudo chown -R ubuntu:ubuntu /home/ubuntu/simulator
sudo chmod -R 755 /home/ubuntu/simulator
# if the container (running as a non-ubuntu user) needs write access to outputs:
sudo chmod -R 775 /home/ubuntu/simulator/deployed /home/ubuntu/simulator/archived /home/ubuntu/simulator/jim_logs

# 5. Fetch your compiled image and run it continuously using background terminal streams
# Make sure to swap out the placeholder text below with your actual Docker Hub image name!
sudo docker pull jhazelton55/deployment-simulator:latest
sudo docker run -d -t \
  --name python-deployment-simulator \
  -v /home/ubuntu/simulator/deployed:/app/deployed \
  -v /home/ubuntu/simulator/archived:/app/archived \
  -v /home/ubuntu/simulator/jim_logs:/app/jim_logs \
  jhazelton55/deployment-simulator:latest
