# Deployment Simulator Infrastructure (IaC)

This repository contains the Infrastructure as Code (IaC) configuration to automatically provision a secure AWS environment and deploy the containerized Deployment Simulator application. 

This project represents the Continuous Deployment (CD) and infrastructure provisioning layer of a complete CI/CD workflow.

Together with the companion Deployment Simulator repository, this project demonstrates the complete lifecycle from application development and continuous integration through automated cloud infrastructure provisioning and deployment.

## Why This Project?
Modern Platform Engineers and Release Automation Engineers are expected to automate not only application deployments but also the infrastructure required to host them.

I built this project to demonstrate practical Platform Engineering and Release Automation skills using modern cloud-native tooling. Together with the companion Deployment Simulator repository, it demonstrates a complete CI/CD workflow—from Python application development and GitHub Actions continuous integration to Docker image publication, Terraform infrastructure provisioning, automated deployment on AWS, and infrastructure teardown.

The project demonstrates practical experience with:

- Infrastructure as Code (Terraform)
- AWS infrastructure provisioning
- Docker container deployment
- GitHub Actions CI integration
- Automated EC2 bootstrapping
- End-to-end deployment automation
- Repeatable infrastructure lifecycle management using `terraform destroy`

## Skills Demonstrated

- Terraform
- AWS (VPC, EC2, Security Groups)
- Docker
- Docker Hub
- GitHub
- GitHub Actions
- Infrastructure as Code (IaC)
- Continuous Deployment (CD)
- Linux (Ubuntu)
- Automation

## 🔗 Architecture Overview & Pipeline Integration

1. **Application Layer (CI):** The core Python application logic is managed in the [Deployment Simulator Core Repository](https://github.com/jhazelton/Deployment_simulator). Changes there trigger GitHub Actions to build and publish a container image to [Docker Hub](https://hub.docker.com/repository/docker/jhazelton55/deployment-simulator/general).
2. **Infrastructure Layer (CD):** This repository connects directly to **HCP Terraform** via webhooks. Every commit to the `main` branch automatically triggers a speculative plan and execution run to safely manage AWS infrastructure.

## 🛠️ AWS Infrastructure Topology

The Terraform configuration defines and initializes the following cloud components:
- **Virtual Private Cloud (VPC):** A dedicated, isolated network boundary for the simulator runtime.
- **Public Subnet:** Hosts the compute resources with an attached Internet Gateway for public accessibility.
- **Security Group:** A hardened firewall restricting inbound traffic strictly to essential ports (`22` for SSH management, `80`/`443` for web, and `5000` for application streams) while permitting unrestricted outbound routing.
- **EC2 Compute Node:** An Ubuntu server instance configured to automatically execute runtime bootstrap scripting.

## 🚀 Automated Host Bootstrapping (User Data)

At system boot, AWS executes a customized `user_data.sh` initialization script that completely automates the application environment setup:
1. **OS Stabilization:** Pauses briefly to prevent background package locks (`apt` collisions).
2. **Native Runtime Installation:** Installs and enables the Docker container engine cleanly without legacy repository bloat.
3. **Storage Orchestration:** Creates persistent host volume paths (`incoming`, `deployed`, `archived`, and `jim_logs`) with optimized user ownership configurations (`chown`/`chmod`).
4. **Artifact Retrieval & Execution:** Pulls the compiled application image directly from Docker Hub and initializes the container utilizing host-to-container directory mounts (`-v`) to ensure telemetry logs persist directly on the host machine.

## Infrastructure Lifecycle

The environment is intentionally dynamic.  Environment can be spun up or destroyed as needed.

After validation is complete, all AWS resources are removed using:

terraform destroy

This demonstrates repeatable Infrastructure-as-Code practices while minimizing cloud costs by ensuring all provisioned resources are automatically cleaned up after testing.

## What This Project Demonstrates

This project demonstrates my ability to:

- Design Infrastructure as Code using Terraform
- Provision secure AWS infrastructure
- Deploy containerized applications automatically
- Integrate Docker Hub into deployment workflows
- Automate Linux host configuration using EC2 User Data
- Build repeatable deployment environments
- Manage the complete infrastructure lifecycle using `terraform destroy`
