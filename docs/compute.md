# Compute

## Overview

The compute layer runs the Vendure Production Platform using Amazon Elastic Container Service (ECS) with AWS Fargate.

The platform is divided into three independent application workloads:

- Vendure API
- Vendure Worker
- Next.js Storefront

Each workload runs as its own ECS Service and uses a dedicated ECS Task Definition.

AWS Fargate provides serverless container compute, allowing the platform to run containers without managing EC2 instances.

---

## Objectives

The compute architecture was designed to achieve the following goals:

- Run application workloads as containerized services.
- Separate API, worker, and storefront responsibilities.
- Avoid managing EC2 instances directly.
- Run application containers inside private subnets.
- Integrate workloads with Application Load Balancer target groups.
- Automatically maintain the desired number of running tasks.
- Support independent deployment and scaling of each workload.
- Use reusable Terraform modules for ECS infrastructure.

---

## Architecture

The compute architecture consists of:

- **1 ECS Cluster**
- **3 ECS Task Definitions**
- **3 ECS Services**
- **3 ECS Task Execution Roles**
- **AWS Fargate compute**
- **2 Docker Images**
- **CloudWatch log integration**


                     ECS Cluster
                          │
      ┌───────────────────┼───────────────────┐
      │                   │                   │
      ▼                   ▼                   ▼
 API Service        Storefront Service   Worker Service
      │                   │                   │
      ▼                   ▼                   ▼



The API and Storefront services receive traffic through the Application Load Balancer.

The Worker runs background Vendure jobs and does not receive public HTTP traffic.

---

## Components

### ECS Cluster

Amazon ECS provides the container orchestration layer for the platform.

The ECS Cluster acts as the logical environment in which the three application services run.

Cluster:

The cluster uses AWS Fargate as the compute engine.

Container Insights is enabled to improve visibility into ECS workload performance.

---

### AWS Fargate

AWS Fargate is used to run ECS tasks without provisioning or managing EC2 instances.

Responsibilities include:

- Providing CPU and memory for containers.
- Creating network interfaces for tasks.
- Running tasks inside private subnets.
- Integrating with ECS Services and Task Definitions.

Each task uses the `awsvpc` network mode.

This gives every running task its own network interface and private IP address.

---

### ECS Task Execution Roles

Each workload uses an ECS Task Execution Role.

Execution roles allow ECS to perform infrastructure-level actions required before and during container startup.

Responsibilities include:

- Pulling Docker images from Amazon ECR.
- Sending container logs to CloudWatch.
- Retrieving secrets from AWS Secrets Manager.

Three execution roles are configured:

- API Task Execution Role
- Worker Task Execution Role
- Storefront Task Execution Role

The API and Worker execution roles are additionally allowed to retrieve the RDS-managed database secret.

The Storefront does not require database secret access.

---

### ECS Task Definitions

Task Definitions describe how each container should run.

They define:

- Docker image
- CPU
- Memory
- Container name
- Runtime command
- Environment variables
- Secrets
- Port mappings
- CloudWatch logging configuration
- ECS Task Execution Role

Three Task Definitions are used.

---

#### Vendure API Task Definition

The API runs the Vendure server.

Runtime command: node apps/server/dist/index.js


Container port: 3000

CPU: 512
Memory: 1024 MB

Responsibilities:

- Vendure Shop API
- Vendure Admin API
- Dashboard
- Asset requests
- Application health endpoint

The API connects directly to PostgreSQL RDS.

---

#### Vendure Worker Task Definition

The Worker uses the same Vendure server Docker image as the API.

Runtime command: node apps/server/dist/index-worker.js


Resources: 

CPU: 512
Memory: 1024 MB

Responsibilities:

- Background jobs
- Vendure job queue processing
- Asynchronous application workloads

The Worker does not expose an HTTP port and does not connect to the Application Load Balancer.

The Worker connects directly to PostgreSQL RDS.

---

#### Storefront Task Definition

The Storefront runs the production Next.js application.

Runtime command: node apps/storefront/server.js

Container port: 3001

Resources:

CPU: 512
Memory: 1024 MB

Responsibilities:

- Customer-facing storefront
- Server-side rendering
- Product browsing interface
- Communication with the Vendure API

The Storefront does not connect directly to PostgreSQL.

Application data is retrieved through the Vendure API.

---

## ECS Services

ECS Services maintain the desired state of application workloads.

Three services are configured:

- Vendure API Service
- Vendure Storefront Service
- Vendure Worker Service

Each service:

- Uses its corresponding Task Definition.
- Runs using AWS Fargate.
- Runs inside private subnets.
- Uses a workload-specific Security Group.
- Maintains the configured desired task count.

Current build-stage desired count: 1 task per service


Production scaling can be increased later based on availability and traffic requirements.

---

### API ECS Service

Service: vendure-api-service


The API Service:

- Uses the API Task Definition.
- Runs in both private subnets.
- Uses the ECS API Security Group.
- Registers running task IP addresses with the API Target Group.
- Receives traffic on port `3000`.

---

### Storefront ECS Service

Service: vendure-storefront-service


The Storefront Service:

- Uses the Storefront Task Definition.
- Runs in both private subnets.
- Uses the ECS Storefront Security Group.
- Registers running task IP addresses with the Storefront Target Group.
- Receives traffic on port `3001`.

---

### Worker ECS Service

Service: vendure-worker-service


The Worker Service:

- Uses the Worker Task Definition.
- Runs in both private subnets.
- Uses the ECS Worker Security Group.
- Does not register with an ALB Target Group.
- Does not expose an application port.

The Worker performs internal background processing only.

---

## ECS Service Lifecycle

ECS Services continuously maintain the desired number of running tasks.

For example:  Desired Tasks = 1
│
▼
ECS starts task
│
▼
Task receives private IP
│
▼
Container starts


For load-balanced services: Task starts
│
▼
Private IP assigned
│
▼
ECS registers IP
with Target Group
│
▼
ALB health check
│
▼
Healthy target
│
▼
Traffic allowed


If a task stops unexpectedly, ECS automatically starts a replacement task.

---

## Networking Integration

All ECS Tasks run inside the private subnets.

Private Subnet A
Private Subnet B
│
▼
ECS Tasks


Tasks are not assigned public IP addresses.

Configuration: assign_public_ip = false



Outbound internet connectivity is provided through the NAT Gateways.

This allows tasks to access services such as:

- Amazon ECR
- AWS Secrets Manager
- External package or API endpoints

while keeping the application workloads inaccessible directly from the public internet.

---

## Load Balancer Integration

Only the API and Storefront services connect to the Application Load Balancer.





Outbound internet connectivity is provided through the NAT Gateways.

This allows tasks to access services such as:

- Amazon ECR
- AWS Secrets Manager
- External package or API endpoints

while keeping the application workloads inaccessible directly from the public internet.

---

## Load Balancer Integration

Only the API and Storefront services connect to the Application Load Balancer.


Application Load Balancer
│
├───────────────► API Target Group
│ │
│ ▼
│ API ECS Service
│
└───────────────► Storefront Target Group
│
▼
Storefront ECS Service


The Worker does not connect to the ALB.

---

## Logging

All application containers send logs to Amazon CloudWatch Logs using the ECS `awslogs` log driver.

Log groups:

/ecs/vendure-production/api

/ecs/vendure-production/worker

/ecs/vendure-production/storefront



CloudWatch provides centralized application logging for troubleshooting and operational visibility.

---

## Secrets Integration

Database credentials are not hardcoded inside:

- Terraform variables
- Docker images
- Source code
- Environment configuration files

Amazon RDS manages the master database password through AWS Secrets Manager.

The API and Worker Task Definitions receive the required database credentials securely during container startup.

RDS
│
▼
Secrets Manager
│
▼
ECS Task Execution Role
│
▼
API / Worker Container



This prevents database passwords from being stored directly in the repository.

---

## High Availability Design

The ECS Services use both private subnets located in separate Availability Zones.

Availability Zone A Availability Zone B

Private Subnet A Private Subnet B
│ │
└──────── ECS Service ───────┘


This allows ECS to place application tasks across multiple Availability Zones.

The architecture therefore supports future horizontal scaling without redesigning the network.

---

## Terraform Implementation

The compute infrastructure is implemented using reusable Terraform modules.

Modules include:

- ECS Cluster
- ECS Task Execution Role
- ECS Task Definition
- ECS Service
- CloudWatch Log Groups

A single reusable ECS Service module supports all three workloads.

Terraform uses `for_each` to create:

module.ecs_service["api"]

module.ecs_service["storefront"]

module.ecs_service["worker"]


The same module is reused with different configuration values.

---

## Reusable ECS Service Design

The API and Storefront require Load Balancer integration.

The Worker does not.

The ECS Service module therefore uses an optional dynamic Load Balancer block.


This allows one Terraform module to support all three workloads without duplicating infrastructure code.

---

## Security Considerations

The compute architecture follows the principle of least exposure.

Implemented practices include:

- ECS Tasks run only inside private subnets.
- Tasks are not assigned public IP addresses.
- API traffic is accepted only from the ALB Security Group.
- Storefront traffic is accepted only from the ALB Security Group.
- Worker tasks are not accessible through the ALB.
- PostgreSQL access is limited to API and Worker Security Groups.
- Database secrets are retrieved through AWS Secrets Manager.
- Docker images are pulled from private Amazon ECR repositories.
- Application logs are centralized in CloudWatch.

---

## Design Decisions

### Why use AWS Fargate?

Fargate removes the need to manage EC2 container hosts.

Benefits include:

- No EC2 patching.
- No host operating system management.
- Native integration with ECS.
- Simple workload scaling.
- Per-task resource allocation.

---

### Why separate API, Worker, and Storefront services?

Each workload has a different responsibility.

Separating them allows:

- Independent deployment.
- Independent scaling.
- Better fault isolation.
- Separate logs.
- Separate security policies.
- Clear operational ownership.

---

### Why do API and Worker use the same Docker image?

The Vendure API and Worker are built from the same application source.

The difference is the runtime command.

API: node apps/server/dist/index.js

Worker: node apps/server/dist/index-worker.js


Using the same image reduces duplicate builds while allowing the workloads to operate independently.

---

### Why does the Worker not use the Application Load Balancer?

The Worker does not process incoming HTTP requests.

It performs background Vendure jobs.

Therefore:

- No target group is required.
- No listener rule is required.
- No public traffic should reach the Worker.

---

### Why use ECS Services instead of running standalone tasks?

ECS Services maintain the desired application state.

If a task fails:

Task failure
│
▼
ECS detects failure
│
▼
Replacement task started


This provides automatic workload recovery and prepares the platform for future scaling and deployment automation.

---


