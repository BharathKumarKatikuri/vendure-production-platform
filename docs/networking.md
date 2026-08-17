# Networking

## Overview

The networking layer provides the foundation for the Vendure Production Platform. It is designed using AWS Virtual Private Cloud (VPC) best practices to provide secure, scalable, and highly available networking for containerized workloads.

The infrastructure is distributed across two Availability Zones to improve fault tolerance and availability. Public resources are isolated from private application resources through subnet segregation and controlled routing.

---

## Objectives

The networking architecture was designed to achieve the following goals:

- Isolate infrastructure within a dedicated VPC.
- Separate public and private workloads.
- Provide outbound internet access for private resources.
- Support high availability across multiple Availability Zones.
- Build a reusable networking foundation for future infrastructure components.

---

## Architecture

The networking topology consists of:

- **1 Virtual Private Cloud (VPC)**
- **2 Public Subnets**
- **2 Private Subnets**
- **1 Internet Gateway**
- **2 NAT Gateways**
- **2 Elastic IPs**
- **1 Public Route Table**
- **2 Private Route Tables**

```
                    Internet
                        │
                Internet Gateway
                        │
        ┌───────────────┴───────────────┐
        │                               │
 Public Subnet A                 Public Subnet B
     │                               │
 NAT Gateway A                  NAT Gateway B
     │                               │
 Private Subnet A              Private Subnet B

```

Each Availability Zone contains:

- One public subnet
- One private subnet
- One NAT Gateway

This architecture eliminates a single point of failure for outbound internet connectivity.

---

## Components

### Virtual Private Cloud (VPC)

The VPC provides logical network isolation for all AWS resources deployed as part of the platform.

Configuration:

- CIDR Block: `10.0.0.0/16`
- DNS Hostnames: Enabled
- DNS Resolution: Enabled

---

### Public Subnets

Two public subnets are deployed across separate Availability Zones.

Responsibilities:

- Internet-facing resources
- NAT Gateways
- Future Application Load Balancer (ALB)

Public subnets automatically assign public IP addresses to launched resources.

---

### Private Subnets

Private subnets host internal application workloads.

Responsibilities:

- ECS Tasks
- Future RDS Database
- Future ElastiCache Cluster

Private subnets have no direct internet access.

---

### Internet Gateway

The Internet Gateway connects the VPC to the public internet.

It is attached to the VPC and referenced by the public route table.

---

### NAT Gateways

Each Availability Zone contains its own NAT Gateway.

Purpose:

- Allow private resources to download packages, container images, and updates.
- Prevent inbound internet connectivity to private workloads.

This design avoids cross-AZ traffic and improves availability.

---

### Elastic IP Addresses

Each NAT Gateway uses a dedicated Elastic IP address.

Elastic IPs provide stable public IP addresses for outbound internet connectivity.

---

### Route Tables

#### Public Route Table

Configured with:

```
0.0.0.0/0 → Internet Gateway
```

Associated with both public subnets.

---

#### Private Route Tables

Each private subnet has its own route table.

Configured with:

```
0.0.0.0/0 → NAT Gateway
```

This allows outbound internet access while preventing inbound connections.

---

## High Availability Design

Networking resources are distributed across two Availability Zones.

Benefits include:

- Increased fault tolerance
- Reduced downtime
- Independent outbound connectivity
- AWS production best practices

---

## Terraform Implementation

The networking infrastructure is implemented using reusable Terraform modules.

Modules include:

- VPC
- Subnets
- Internet Gateway
- Elastic IP
- NAT Gateway
- Route Tables

Each module is designed to be reusable and configurable through variables.

---

## Security Considerations

The networking architecture follows the principle of least exposure.

Implemented practices include:

- Private workloads remain isolated.
- Internet access is restricted through NAT Gateways.
- Public resources are limited to networking infrastructure.
- Separate route tables for public and private traffic.

---

## Design Decisions

### Why two NAT Gateways?

Using one NAT Gateway per Availability Zone:

- Removes a single point of failure.
- Avoids cross-AZ routing charges.
- Aligns with AWS production architecture recommendations.

---

### Why separate route tables?

Independent route tables improve flexibility and allow each subnet to be managed independently.

---

### Why use private subnets?

Application workloads should never be directly exposed to the internet.

Only controlled entry points (such as an Application Load Balancer) should communicate with internal services.

---

