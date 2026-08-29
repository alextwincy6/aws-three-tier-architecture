# AWS 3-Tier Web Application with Auto Scaling

## 📌 Project Overview

This project demonstrates a highly available, scalable, and secure **3-Tier Web Application Architecture** built manually using the **AWS Management Console**.

The application is divided into three separate layers:

1. **Web Tier** – Nginx web servers managed by an Auto Scaling Group
2. **Application Tier** – Backend application servers managed by an Auto Scaling Group
3. **Database Tier** – Amazon RDS MySQL

The infrastructure is distributed across multiple Availability Zones to improve availability, fault tolerance, and scalability.

---

# 🏗️ Architecture

```text
                              INTERNET
                                  |
                                  ↓
                         Internet Gateway
                                  |
                                  ↓
                    Application Load Balancer
                                  |
                                  ↓
                         Web Target Group
                                  |
                    ┌─────────────┴─────────────┐
                    ↓                           ↓
              WEB ASG - AZ1               WEB ASG - AZ2
                    ↓                           ↓
              Nginx EC2                    Nginx EC2
                    |                           |
                    └─────────────┬─────────────┘
                                  |
                                  ↓
                         App Target Group
                                  |
                    ┌─────────────┴─────────────┐
                    ↓                           ↓
              APP ASG - AZ1               APP ASG - AZ2
                    ↓                           ↓
             Flask/App EC2                 Flask/App EC2
                    |                           |
                    └─────────────┬─────────────┘
                                  |
                                  ↓
                         Database Tier
                                  |
                             Amazon RDS
                              MySQL
```

---

# ☁️ AWS Services Used

| AWS Service               | Purpose                                                |
| ------------------------- | ------------------------------------------------------ |
| Amazon VPC                | Creates the isolated network                           |
| Availability Zones        | Provides high availability                             |
| Subnets                   | Separates Web, Application and Database tiers          |
| Internet Gateway          | Provides internet connectivity                         |
| NAT Gateway               | Provides outbound internet access to private resources |
| Route Tables              | Controls network traffic                               |
| Security Groups           | Controls network access between tiers                  |
| Amazon EC2                | Hosts Web and Application servers                      |
| Launch Templates          | Defines EC2 configuration for Auto Scaling             |
| Auto Scaling Groups       | Automatically maintains and scales EC2 instances       |
| Nginx                     | Web server and reverse proxy                           |
| Application Load Balancer | Distributes incoming traffic                           |
| Target Groups             | Registers and health-checks EC2 instances              |
| Amazon RDS                | Hosts the MySQL database                               |
| CloudWatch                | Monitoring and Auto Scaling metrics                    |
| IAM                       | Provides permissions to AWS resources                  |

---

# 🌐 Network Architecture

## VPC

```text
VPC CIDR:
10.0.0.0/16
```

The VPC provides the private network for all project resources.

---

# 📦 Subnet Design

The project uses six subnets across two Availability Zones.

| Tier        | Availability Zone | CIDR         | Type    |
| ----------- | ----------------- | ------------ | ------- |
| Web         | ap-south-1a       | 10.0.1.0/24  | Public  |
| Web         | ap-south-1b       | 10.0.2.0/24  | Public  |
| Application | ap-south-1a       | 10.0.11.0/24 | Private |
| Application | ap-south-1b       | 10.0.12.0/24 | Private |
| Database    | ap-south-1a       | 10.0.21.0/24 | Private |
| Database    | ap-south-1b       | 10.0.22.0/24 | Private |

### Subnet Architecture

```text
                         VPC
                     10.0.0.0/16
                           |
             ┌─────────────┴─────────────┐
             |                           |
           AZ-1a                       AZ-1b
             |                           |
       ┌─────┼─────┐               ┌─────┼─────┐
       |     |     |               |     |     |
      Web   App    DB             Web   App    DB
       |     |     |               |     |     |
     .1/24 .11/24 .21/24         .2/24 .12/24 .22/24
```

---

# 🔐 Security Architecture

Separate Security Groups are used for each layer.

```text
ALB-SG
   ↓
Web-SG
   ↓
App-SG
   ↓
DB-SG
```

---

## ALB Security Group

Allows users to access the Application Load Balancer.

```text
Inbound:

HTTP 80
Source: 0.0.0.0/0

HTTPS 443
Source: 0.0.0.0/0
```

HTTPS will be configured later.

---

## Web Tier Security Group

Allows HTTP traffic only from the ALB.

```text
Inbound:

HTTP 80
Source: ALB-SG
```

The Web Tier should not be directly accessible from the public internet.

---

## Application Tier Security Group

Allows application traffic only from the Web Tier.

For a Flask application:

```text
Inbound:

TCP 5000
Source: Web-SG
```

---

## Database Security Group

Allows MySQL traffic only from the Application Tier.

```text
Inbound:

MySQL 3306
Source: App-SG
```

The database does not allow direct internet access.

---

# 🔄 Traffic Flow

The complete request flow is:

```text
User
 ↓
Internet
 ↓
Internet Gateway
 ↓
Application Load Balancer
 ↓
Web Target Group
 ↓
Web Auto Scaling Group
 ↓
Nginx
 ↓
Application Target Group
 ↓
Application Auto Scaling Group
 ↓
Application
 ↓
Amazon RDS
```

---

# 🌍 Web Tier

The Web Tier consists of Nginx web servers running on EC2 instances.

The EC2 instances are managed by an **Auto Scaling Group**.

```text
Web Launch Template
        ↓
Web Auto Scaling Group
        ↓
┌───────┴────────┐
↓                ↓
EC2 - AZ1       EC2 - AZ2
Nginx            Nginx
```

### Web ASG Configuration

Planned configuration:

```text
Minimum capacity: 2
Desired capacity: 2
Maximum capacity: 4
```

The Auto Scaling Group distributes instances across multiple Availability Zones.

---

# ⚙️ Application Tier

The Application Tier contains backend application servers.

Example:

```text
Python
Flask
```

The application servers run in private subnets.

```text
App Launch Template
        ↓
App Auto Scaling Group
        ↓
┌───────┴────────┐
↓                ↓
App EC2 - AZ1   App EC2 - AZ2
Flask            Flask
```

### App ASG Configuration

Planned configuration:

```text
Minimum capacity: 2
Desired capacity: 2
Maximum capacity: 4
```

---

# 📈 Auto Scaling

Auto Scaling is used to automatically maintain and adjust the number of EC2 instances.

## Web Auto Scaling Group

```text
Minimum: 2
Desired: 2
Maximum: 4
```

## Application Auto Scaling Group

```text
Minimum: 2
Desired: 2
Maximum: 4
```

When traffic increases, Auto Scaling can launch additional EC2 instances.

Example:

```text
Normal Traffic

EC2
EC2
```

High traffic:

```text
EC2
EC2
EC2
EC2
```

When demand decreases, instances can be terminated according to the configured scaling policy.

---

# 📋 Launch Templates

Launch Templates are used to define how EC2 instances should be created.

A Launch Template can define:

* AMI
* Instance type
* Security Group
* IAM role
* User data
* Storage
* Network configuration

The Auto Scaling Group uses the Launch Template to launch consistent EC2 instances.

---

# ⚖️ Application Load Balancer

The Application Load Balancer receives incoming requests from users.

```text
                    ALB
                     |
             Web Target Group
                     |
          ┌──────────┴──────────┐
          ↓                     ↓
       Web EC2               Web EC2
       Nginx                 Nginx
```

The ALB performs health checks and sends traffic only to healthy targets.

---

# 🎯 Target Groups

Target Groups are used to register EC2 instances with the Load Balancer.

## Web Target Group

```text
Protocol: HTTP
Port: 80
Health Check Path: /
```

The Web Auto Scaling Group will be associated with the Web Target Group.

---

## Application Target Group

Example:

```text
Protocol: HTTP
Port: 5000
Health Check Path: /
```

The Application Auto Scaling Group will be associated with the Application Target Group if the web tier forwards application traffic through a load-balanced application target group.

---

# ❤️ Health Checks

Health checks determine whether EC2 instances are healthy.

Example:

```text
Web Server 1 → Healthy
Web Server 2 → Healthy
```

If an instance becomes unhealthy:

```text
ALB
 ↓
Stops sending traffic to unhealthy instance
```

The Auto Scaling Group can replace an unhealthy instance.

---

# 🗄️ Database Tier

The Database Tier uses **Amazon RDS for MySQL**.

RDS is deployed using private database subnets.

```text
DB Subnet 1
10.0.21.0/24

DB Subnet 2
10.0.22.0/24
```

Public access is disabled.

Only the Application Tier can connect to the database.

```text
Application EC2
      ↓
    TCP 3306
      ↓
     RDS
```

---

# 🌐 Internet Gateway

The Internet Gateway provides connectivity between the VPC and the internet for resources using appropriate public routing and addressing.

```text
Internet
   ↓
Internet Gateway
   ↓
Public Subnets
```

The Application Load Balancer uses the public subnets.

---

# 🔀 NAT Gateway

The NAT Gateway provides outbound internet connectivity to resources in private subnets.

```text
Private App EC2
      ↓
NAT Gateway
      ↓
Internet Gateway
      ↓
Internet
```

This allows private application servers to download packages and updates without requiring public IP addresses.

---

# 🛣️ Route Tables

## Public Route Table

```text
Destination:
0.0.0.0/0

Target:
Internet Gateway
```

Associated with:

```text
Web Public Subnet 1
Web Public Subnet 2
```

---

## Private Application Route Table

```text
Destination:
0.0.0.0/0

Target:
NAT Gateway
```

Associated with:

```text
App Private Subnet 1
App Private Subnet 2
```

---

## Private Database Route Table

The database tier does not require a default route to the public internet for this architecture.

Associated with:

```text
DB Private Subnet 1
DB Private Subnet 2
```

---

# 🔒 Security Design

The project follows a layered security model.

```text
                    INTERNET
                        |
                        | 80/443
                        ↓
                     ALB-SG
                        |
                        | 80
                        ↓
                     Web-SG
                        |
                        | 5000
                        ↓
                     App-SG
                        |
                        | 3306
                        ↓
                     DB-SG
                        |
                        ↓
                       RDS
```

Only the required communication between tiers is allowed.

---

# 📊 CloudWatch Monitoring

CloudWatch will be used to monitor the infrastructure.

Metrics include:

* EC2 CPU utilization
* EC2 status checks
* ALB request count
* ALB target health
* RDS CPU utilization
* RDS database connections
* RDS storage

CloudWatch metrics can also be used with Auto Scaling policies.

---

# 📈 Auto Scaling Policy

A target tracking policy can be configured based on average CPU utilization.

Example:

```text
Target CPU:
60%
```

Example behavior:

```text
CPU increases
      ↓
Auto Scaling launches instances
      ↓
More capacity
```

And:

```text
CPU decreases
      ↓
Auto Scaling reduces capacity
```

The exact scaling behavior depends on the configured policy and AWS service timing.

---

# 🚀 Deployment Steps

## Phase 1 — Network

* Create VPC
* Create six subnets
* Create Internet Gateway
* Create public route table
* Create private application route table
* Create private database route table
* Create NAT Gateway
* Associate subnets with route tables

---

## Phase 2 — Security

* Create ALB Security Group
* Create Web Security Group
* Create Application Security Group
* Create Database Security Group
* Configure least-privilege inbound rules

---

## Phase 3 — Web Tier

* Create Web Launch Template
* Install Nginx using User Data
* Configure Nginx
* Create Web Target Group
* Create Web Auto Scaling Group
* Configure minimum, desired and maximum capacity

---

## Phase 4 — Application Tier

* Create Application Launch Template
* Install Python
* Install Flask
* Deploy backend application
* Create Application Target Group
* Create Application Auto Scaling Group
* Configure application health checks

---

## Phase 5 — Database Tier

* Create DB subnet group
* Create Amazon RDS MySQL
* Disable public access
* Configure DB Security Group
* Connect Application Tier to RDS

---

## Phase 6 — Load Balancing

* Create Application Load Balancer
* Select two public subnets
* Configure ALB Security Group
* Configure listeners
* Configure Web Target Group
* Verify target health

---

## Phase 7 — Auto Scaling

* Configure Web Auto Scaling Group
* Configure Application Auto Scaling Group
* Configure scaling policies
* Test scale-out
* Test scale-in
* Test unhealthy instance replacement

---

## Phase 8 — Monitoring

* Configure CloudWatch
* Monitor EC2
* Monitor ALB
* Monitor RDS
* Create CloudWatch alarms

---

# 🧪 Testing

## Test 1 — ALB Access

Access:

```text
http://<ALB-DNS-NAME>
```

Expected:

```text
Application loads successfully
```

---

## Test 2 — Web Tier Health

Verify:

```text
Web EC2 1 → Healthy
Web EC2 2 → Healthy
```

---

## Test 3 — Application Connectivity

Verify:

```text
Nginx Web Tier
       ↓
Application Tier
```

---

## Test 4 — Database Connectivity

Verify:

```text
Application Tier
       ↓
TCP 3306
       ↓
RDS MySQL
```

---

## Test 5 — Auto Scaling

Increase application load or CPU utilization.

Expected:

```text
Desired:
2 EC2

        ↓

Additional EC2 instances launched
```

Verify that the new instances become healthy targets.

---

## Test 6 — Instance Failure

Terminate one EC2 instance managed by an Auto Scaling Group.

Expected:

```text
Unhealthy/terminated instance
          ↓
ASG detects capacity loss
          ↓
Replacement EC2 launched
          ↓
Instance becomes healthy
```

---

## Test 7 — Security

Verify:

```text
Internet → RDS
```

is not allowed.

Verify:

```text
Internet → App EC2
```

is not directly allowed.

Verify that only the ALB can access the Web Tier.

---

# 📸 Project Screenshots

Screenshots of the AWS infrastructure will be stored in the `screenshots/` directory.

```text
screenshots/
│
├── vpc.png
├── subnets.png
├── route-tables.png
├── internet-gateway.png
├── nat-gateway.png
├── security-groups.png
├── web-launch-template.png
├── web-asg.png
├── web-ec2.png
├── nginx.png
├── app-launch-template.png
├── app-asg.png
├── app-ec2.png
├── target-groups.png
├── alb.png
├── rds.png
├── cloudwatch.png
├── autoscaling.png
└── final-application.png
```

---

# 📁 Project Structure

```text
aws-3-tier-web-application/
│
├── README.md
│
├── architecture/
│   └── aws-3-tier-architecture.png
│
├── screenshots/
│   ├── vpc.png
│   ├── subnets.png
│   ├── route-tables.png
│   ├── security-groups.png
│   ├── web-asg.png
│   ├── app-asg.png
│   ├── alb.png
│   ├── rds.png
│   └── cloudwatch.png
│
├── web-tier/
│   ├── nginx.conf
│   └── index.html
│
├── app-tier/
│   ├── app.py
│   └── requirements.txt
│
├── database/
│   └── schema.sql
│
└── documentation/
    ├── network-design.md
    ├── security-groups.md
    ├── autoscaling.md
    └── deployment.md
```

---

# 🛡️ Security Best Practices

* Use private subnets for Application and Database tiers.
* Disable public access for RDS.
* Allow database traffic only from the Application Security Group.
* Allow application traffic only from the Web Security Group.
* Allow Web Tier traffic only from the ALB Security Group.
* Restrict SSH access to a trusted source.
* Prefer AWS Systems Manager Session Manager where practical.
* Use IAM roles instead of hard-coded AWS credentials.
* Never commit AWS access keys to GitHub.
* Never commit private `.pem` keys to GitHub.
* Never commit database passwords or secrets.
* Use HTTPS in the final version.

---

# 💰 Cost Considerations

AWS resources can incur charges depending on account type, region, usage, and current AWS pricing/free-tier eligibility.

Potentially chargeable resources include:

* NAT Gateway
* EC2
* Application Load Balancer
* RDS
* Public IPv4 addresses
* CloudWatch usage

Resources should be stopped or deleted when the project is no longer being used.

---

# 📚 What I Learned

Through this project, I am gaining hands-on experience with:

* AWS VPC
* CIDR and subnetting
* Public and private subnets
* Availability Zones
* Internet Gateway
* NAT Gateway
* Route Tables
* Security Groups
* Amazon EC2
* Launch Templates
* Auto Scaling Groups
* Scaling Policies
* Nginx
* Reverse Proxy
* Application Load Balancer
* Target Groups
* Health Checks
* Amazon RDS
* MySQL
* CloudWatch
* IAM
* High Availability
* Fault Tolerance
* Network Security
* Three-Tier Architecture

---

# 🎯 Future Improvements

Potential future improvements include:

* Infrastructure as Code using Terraform
* CI/CD using GitHub Actions
* Docker containerization
* Amazon ECS
* AWS EKS
* AWS Secrets Manager
* AWS WAF
* CloudFront
* Centralized logging
* Blue/Green deployment
* Automated testing

---

# 👨‍💻 Project Status

```text
Status: In Progress

Deployment:
Manual AWS Console

Architecture:
Highly Available 3-Tier Web Application

Region:
ap-south-1 (Mumbai)

Web Tier:
Nginx + EC2 + Auto Scaling

Application Tier:
Python Flask + EC2 + Auto Scaling

Database Tier:
Amazon RDS MySQL
```

---

# 📌 Disclaimer

This project is created for educational and hands-on learning purposes.

AWS resources should be monitored and deleted when they are no longer required to avoid unnecessary charges.