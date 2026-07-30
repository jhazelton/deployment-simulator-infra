#!/bin/bash
# 1. Update system packages safely
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get upgrade -y

# 2. Install Docker Engine cleanly
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://docker.com | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://docker.com $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# 3. Create host storage directories matching your Python script definitions
sudo mkdir -p /home/ubuntu/simulator/incoming
sudo mkdir -p /home/ubuntu/simulator/deployed
sudo mkdir -p /home/ubuntu/simulator/archived
sudo mkdir -p /home/ubuntu/simulator/jim_logs

# 4. Generate a default tracking manifest so the initial validation check passes
sudo echo "schema_update.sql" > /home/ubuntu/simulator/deployment_files.txt
sudo touch /home/ubuntu/simulator/incoming/schema_update.sql

# 5. Fix user permissions so the Docker runtime engine can alter files on the host
sudo chown -R ubuntu:ubuntu /home/ubuntu/simulator
sudo chmod -R 777 /home/ubuntu/simulator

# 6. Fetch your compiled image and run it continuously using background terminal streams
# Note: The -d and -t flags keep the one-shot Python process alive in the background!
sudo docker pull jhazelton55/deployment-simulator:latest
sudo docker run -d -t \
  --name python-deployment-simulator \
  -v /home/ubuntu/simulator/deployment_files.txt:/app/deployment_files.txt \
  -v /home/ubuntu/simulator/incoming:/app/incoming \
  -v /home/ubuntu/simulator/deployed:/app/deployed \
  -v /home/ubuntu/simulator/archived:/app/archived \
  -v /home/ubuntu/simulator/jim_logs:/app/jim_logs \
  jhazelton55/deployment-simulator:latest
