How to Use the Terraform Module
=============================

This Terraform module sets up a ClickHouse cluster, Kafka cluster, and AWS API Gateway. To use this module, follow these steps:

### Prerequisites

* Terraform installed on your machine
* AWS credentials set up

### Usage

1. Initialize Terraform: `terraform init`
2. Apply the configuration: `terraform apply`

### Module Overview

This module consists of several sub-modules, each exposing the following resources:

* `ClickHouseCluster`: `modules/ClickHouseCluster/main.tf` - Deploys a ClickHouse cluster using the ClickHouse Operator on EKS
* `KafkaCluster`: `modules/KafkaCluster/main.tf` - Deploys a Kafka cluster on EKS and configures it to send events to the ClickHouse cluster
* `AWSAPIGateway`: `modules/AWSAPIGateway/main.tf` - Sets up an AWS API Gateway with an Authorizer Lambda function that forwards traffic to the Kafka cluster
* `EKS`: `modules/EKS/main.tf` - Provisions an EKS cluster
* `LambdaFunction`: `modules/LambdaFunction/main.tf` - Creates an Authorizer Lambda function
* `lambda_function`: `lambda_function.py` - Python code for the Authorizer Lambda function

These resources can be imported and used individually in your Terraform configuration.

### Resources Created

The following resources will be created:

* ClickHouse cluster
* Kafka cluster
* AWS API Gateway
* EKS cluster
* Lambda function

### Note

Make sure to update the AWS credentials and other variables according to your requirements.