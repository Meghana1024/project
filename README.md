Architecture

High-Level Design
Internet
   │
   ▼
Application Load Balancer (Public Subnets)
   │
   ▼
Private Web Servers (EC2 x2 across AZs)
   ▲
   │
Bastion Host (Public Subnet)
Architecture Components

1. VPC
	•	CIDR Block: 10.0.0.0/16
	•	Custom networking configuration
	•	Public and private subnet separation

Uses Amazon VPC to isolate network resources.

⸻

2. Public Subnets (2 Availability Zones)

Resources deployed:
	•	Application Load Balancer
	•	Bastion Host

Purpose:
	•	Accept incoming internet traffic
	•	Provide secure SSH entry point

⸻

3. Private Subnets (2 Availability Zones)

Resources deployed:
	•	Web Server 1
	•	Web Server 2

These servers do not have public internet access.

⸻

4. Application Load Balancer

Uses Application Load Balancer

Features:
	•	Public-facing load balancer
	•	Round-robin traffic distribution
	•	Health checks enabled
	•	High availability across multiple availability zones

⸻

5. Bastion Host

A public Amazon EC2 instance used to securely access private instances.

Responsibilities:
	•	SSH access to private web servers
	•	Running Ansible playbooks

⸻

6. Web Servers

Each web server runs:
	•	Ubuntu 22.04
	•	Nginx

Nginx installation and configuration are automated using Ansible.

The deployed web page displays:
	•	Instance ID
	•	Hostname
	•	Deployment Time

⸻

Security Design

This architecture follows production security best practices.

Network Isolation
	•	Web servers are deployed inside private subnets
	•	No direct internet access to private instances
 SSH Access Flow
   Internet → Bastion Host → Web Servers
 HTTP Access Flow
 Internet → ALB → Web Servers
 Security groups allow:
	•	SSH from internet → Bastion
	•	SSH from Bastion → Web Servers
	•	HTTP from ALB → Web Servers
Project Structure
project-root/
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── provider.tf
│   └── outputs.tf
│
└── ansible/
    ├── inventory.ini
    ├── playbook.yml
    └── roles/
        └── nginx/
            ├── tasks/
            │   └── main.yml
            └── templates/
                └── index.html.j2
Prerequisites

Install the following tools before starting:
	•	AWS CLI
	•	Terraform
	•	Ansible

You will also need:
	•	AWS account
	•	IAM credentials configured
	•	Existing AWS key pair (example: meghana-mumbai.pem)

⸻

AWS Authentication Setup

Terraform authenticates AWS using the following order:
	1.	Environment variables
	2.	AWS CLI credentials (~/.aws/credentials)
	3.	IAM Role (if running inside EC2)

Verify authentication using:
aws sts get-caller-identity
If it returns account details, authentication is successful.

⸻

Infrastructure Deployment

Initialize Terraform
terraform init
Validate Terraform Configuration
terraform validate
Plan Infrastructure
terraform plan
Apply Infrastructure

Replace with your current public IP address:
terraform apply -var="my_ip=YOUR_PUBLIC_IP/32"
Example:
terraform apply -var="my_ip=110.224.103.3/32"
This will create:
	•	VPC
	•	Subnets
	•	Security Groups
	•	Bastion Host
	•	Web Servers
	•	Application Load Balancer

⸻

Access Bastion Host

SSH into the bastion instance:
ssh -i meghana-mumbai.pem ubuntu@<bastion-public-ip>
Transfer SSH Key to Bastion

From your local machine:
scp -i meghana-mumbai.pem meghana-mumbai.pem ubuntu@<bastion-ip>:/home/ubuntu/
Inside the bastion host:
mkdir -p ~/keys
mv meghana-mumbai.pem ~/keys/
chmod 400 ~/keys/meghana-mumbai.pem
Test SSH Access to Private Servers

From bastion host:
ssh -i ~/keys/meghana-mumbai.pem ubuntu@10.0.11.225
If the connection succeeds:
	•	Security groups are configured correctly
	•	Bastion connectivity is working
Exit back to bastion:
exit
Install Ansible on Bastion
sudo apt update
sudo apt install -y ansible
Configure Ansible Directory
mkdir -p ~/ansible-assignment/roles/nginx/{tasks,templates}
cd ~/ansible-assignment
Create files:
	•	inventory.ini
	•	playbook.yml
	•	roles/nginx/tasks/main.yml
	•	roles/nginx/templates/index.html.j2

⸻

Run Ansible Playbook
Inside the ansible directory:
ansible-playbook -i inventory.ini playbook.yml
This will:
	•	Install Nginx
	•	Start Nginx service
	•	Deploy the HTML template

⸻

Access the Application

Retrieve the load balancer DNS:
terraform output alb_dns_name
Open in browser:
http://<alb-dns>
The webpage will display:
	•	Instance ID
	•	Hostname
	•	Deployment Time

⸻

Test Using Curl
curl -H "Connection: close" http://<alb-dns>
Destroy Infrastructure

To remove all AWS resources:
terraform destroy -var="my_ip=YOUR_PUBLIC_IP/32"
Resources deleted:
	•	EC2 instances
	•	Application Load Balancer
	•	VPC
	•	Subnets
	•	Security Groups
	•	NAT Gateway
	•	Internet Gateway

⸻

Technologies Used
	•	Amazon Web Services
	•	Terraform
	•	Ansible
	•	Nginx
	•	Ubuntu 22.04

⸻

Key Features
	•	Multi-AZ high availability
	•	Infrastructure as Code deployment
	•	Secure private subnet architecture
	•	Role-based Ansible configuration
	•	Dynamic webpage templating using Jinja2
	•	Automated infrastructure lifecycle

⸻

Conclusion

This project demonstrates:
	•	Production-style AWS architecture
	•	Secure network segmentation
	•	Automated infrastructure provisioning using Terraform
	•	Automated server configuration using Ansible
	•	High availability using an Application Load Balancer
	•	Clean infrastructure lifecycle management

