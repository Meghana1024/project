# project
Architecture:

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
 Components
1️⃣ VPC
●	CIDR: 10.0.0.0/16

●	Custom networking configuration

2️⃣ Public Subnets (2 AZs)
●	Hosts:

○	Application Load Balancer

○	Bastion Host

3️⃣ Private Subnets (2 AZs)
●	Hosts:

○	Web Server 1
○	Web Server 2

4️⃣ Application Load Balancer
●	Public-facing

●	Round-robin traffic distribution

●	Health checks enabled

5️⃣ Bastion Host
●	Public EC2 instance

●	Used to:

○	SSH into private instances

○	Run Ansible playbook

6️⃣ Web Servers
●	Ubuntu 22.04

●	Nginx installed via Ansible

●	HTML deployed using Jinja2 template

●	Displays:

○	Instance ID

○	Hostname

○	Deployment time
 Security Design
●	Web servers are deployed in private subnets

●	No direct public SSH access to web servers

●	SSH allowed only:

○	Internet → Bastion

○	Bastion → Web Servers

●	HTTP allowed only:

○	ALB → Web Servers

This follows production security best practices.
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
 Deployment Instructions
 Prerequisites
●	AWS CLI configured

●	Terraform installed

●	Ansible installed

●	Existing AWS Key Pair (e.g., mumbai-msrout22.pem)

Step 1 – Initialize Terraform
terraform init
Step 2 – Apply Infrastructure
Replace with your current public IP:
terraform apply -var="my_ip=YOUR_PUBLIC_IP/32"
Confirm with yes.
Step 4 – SSH into Bastion
ssh -i meghana-mumbai.pem ubuntu@<bastion-public-ip>
Step 5 – Run Ansible Playbook
Inside bastion:
#  cd ansible
#  ansible-playbook -i inventory.ini playbook.yml
This will:
●	Install Nginx

●	Deploy template

●	Configure web servers
Step 6 – Access Application

Retrieve ALB DNS:
terraform output alb_dns_name
Open in browser:
http://<alb-dns>
The page will display:
●	Instance ID

●	Hostname

●	Deployment Time
 Destroy Infrastructure
To remove all AWS resources:
terraform destroy -var="my_ip=YOUR_PUBLIC_IP/32"
Confirm with yes
This will clean up:
●	EC2 instances

●	ALB

●	VPC

●	Subnets

●	Security Groups

●	NAT Gateway

●	Internet Gateway

 Key Features
●	Multi-AZ high availability

●	Infrastructure as Code

●	Secure private subnet architecture

●	Role-based Ansible configuration

●	Server-side Jinja2 templating

●	Load balancing validation
 Conclusion
This solution demonstrates:
●	Production-style AWS architecture

●	Secure network segmentation

●	Automated provisioning via Terraform

●	Automated configuration via Ansible

●	High availability using ALB

●	Clean infrastructure lifecycle management
 Technologies Used
●	AWS EC2

●	AWS VPC

●	AWS ALB

●	Terraform

●	Ansible

●	Nginx

●	Ubuntu 22.04





STEPS:

Create an aws ec2 instance then ssh that instance 

install terraform and ansible
and aws cli
then aws configure and give the iam credentials

How Terraform Authenticates (Order of Preference)

Terraform checks in this order:

1️⃣ Environment variables
2️⃣ AWS CLI credentials (~/.aws/credentials)
3️⃣ IAM Role (if running inside EC2)

How To Verify It Works

# aws sts get-caller-identity
If it shows you your account details then it ok

Create a folder terraform and
 # cd terraform
Store the terraform files under the terraform folder like main.tf variables.tf etc

terraform init
terraform validate
terraform plan
terraform apply -var="my_ip=110.224.103.3/32"

open the baston host instance in terminal ssh

mkdir -p ~/ansible-assignment/roles/nginx/{tasks,templates}
cd ~/ansible-assignment

nano inventory.ini

[web]
10.0.11.225
10.0.12.244

[web:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/keys/meghana-mumbai.pem


nano playbook.yml

- name: Configure Nginx Web Servers
  hosts: web
  become: yes
  gather_facts: yes

  vars:
    deployment_time: "{{ ansible_date_time.iso8601 }}"
    instance_id: "{{ ansible_ec2_instance_id | default('N/A') }}"

  roles:
    - nginx


nano roles/nginx/tasks/main.yml

- name: Install Nginx
  apt:
    name: nginx
    state: present
    update_cache: yes

- name: Ensure Nginx is running
  service:
    name: nginx
    state: started
    enabled: yes

- name: Get EC2 Instance ID
  command: curl -s http://169.254.169.254/latest/meta-data/instance-id
  register: ec2_instance_id

- name: Deploy provided index template
  template:
    src: index.html.j2
    dest: /var/www/html/index.html
    mode: '0644'
  vars:
    instance_id: "{{ ec2_instance_id.stdout }}"
    deployment_time: "{{ ansible_date_time.iso8601 }}"


nano roles/nginx/templates/index.html.j2

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Infrastructure Assignment App</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f6f8;
            text-align: center;
            padding: 50px;
        }

        .card {
            background: white;
            max-width: 600px;
            margin: auto;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        h1 {
            color: #2c3e50;
        }

        .meta {
            margin-top: 20px;
            font-size: 14px;
            color: #7f8c8d;
        }

        .footer {
            margin-top: 40px;
            font-size: 12px;
            color: #95a5a6;
        }
    </style>
</head>

<body>

<div class="card">
    <h1>Infrastructure Assignment Application</h1>
    <p>If you can see this page, your infrastructure is working correctly.</p>

    <div class="meta">
        <p><strong>Instance ID:</strong> {{ instance_id }}</p>
        <p><strong>Hostname:</strong> {{ ansible_hostname }}</p>
        <p><strong>Deployment Time:</strong> {{ deployment_time }}</p>
    </div>

    <div class="footer">
        <p>Deployed using Terraform, Ansible, and AWS</p>
    </div>
</div>

<!-- Auto refresh every 2 seconds for demo -->
<script>

&nbsp;   setTimeout(function() {

&nbsp;       window.location.reload();

&nbsp;   }, 2000);


</body>
</html>

Open any terminal where the pem file present but without ssh login then run the below command 
# scp -i meghana-mumbai.pem meghana-mumbai.pem ubuntu@3.110.102.199:/home/ubuntu/

ssh -i meghana-mumbai.pem ubuntu@3.110.102.199

mkdir -p ~/keys
mv meghana-mumbai.pem ~/keys/
chmod 400 ~/keys/meghana-mumbai.pem

now test the private ip inside the bastion host
ssh -i ~/keys/meghana-mumbai.pem ubuntu@10.0.11.225

if it connect then the sg and connection is perfect
now come out from the private ip instance to bastion host by "exit"
install ansible in the bastion host

apt update
apt install -y ansible

under the ansible-assignment folder run the below command
ansible-playbook -i inventory.ini playbook.yml



curl -H "Connection: close" http://tf-lb-20260225174756089900000009-998343255.ap-south-1.elb.amazonaws.com/





