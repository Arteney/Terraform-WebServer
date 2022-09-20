## In this project, GitHub Actions is used to create CI/CD that builds and push Docker image to Amazon ECR, then fills in the new image ID in the Amazon ECS task definition and deploy Amazon ECS task definition.

* Code that run this CI/CD is located at /.github/workflows
* Actions secrets are used to store sensitive repository secrets.
* GitHub Actions is used for both, stage and production.

## On AWS, there is two different VPCs, one that is used for stage, and other one for production.

## Each VPC have:
## Two public subnets, each one in different availability zone. This is used for: 
* NAT Gateway with Public Connectivity – Instances in private subnets can connect to the internet through a public NAT gateway, but cannot receive unsolicited inbound connections from the internet.
* Application Load Balancer
* Bastion Host (EC2 instance) that is used to access to the database, because the database can be accessed only inside VPC (for security reasons).

## Two private subnets, each one in different availability zone. This is used for:
* ECS Cluster with 4 services:
Frontend app, Backend WEB App, Backend Manage App, Backend Worker App

## Two isolated subnets, each one in different availability zone. This is used for:
* RDS - MySql database
* Redis Cluster

## There is also:
* Internet Gateway that enables resources to connect to the internet if the resource has a public IPv4 address or an IPv6 address.
* Amazon ECR that is used as Docker container.
* AWS Secrets Manager used to manage, retrieve, and rotate database credentials, API keys, and other secrets
* Amazon S3 bucket for storage
* Amazon Route 53 as highly available and scalable DNS web service.

## AWS Architecture Diagram:

