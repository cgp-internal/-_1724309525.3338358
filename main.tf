provider "aws" {
  region = var.region
}

variable "region" {
  type        = string
  default     = "us-west-2"
  description = "AWS region"
}

variable "cluster_name" {
  type        = string
  default     = "example"
  description = "Cluster name"
}

# Separate output for each module to allow importing individually
output "EKS" {
  value = module.EKS.EKS
}

output "ClickHouseCluster" {
  value = module.ClickHouseCluster.ClickHouseCluster
}

output "KafkaCluster" {
  value = module.KafkaCluster.cluster
}

output "AWSAPIGateway" {
  value = module.AWSAPIGateway.gateway
}

output "LambdaFunction" {
  value = module.LambdaFunction.lambda_function
}

module "EKS" {
  source = file("./modules/EKS/main.tf")
}

module "ClickHouseCluster" {
  source = file("./modules/ClickHouseCluster/main.tf")

  cluster_name = var.cluster_name
}

module "KafkaCluster" {
  source = file("./modules/KafkaCluster/main.tf")

  cluster_name = var.cluster_name
  eks_cluster = module.EKS.EKS
  clickhouse_cluster = module.ClickHouseCluster.ClickHouseCluster
}

module "AWSAPIGateway" {
  source = file("./modules/AWSAPIGateway/main.tf")

  kafka_cluster = module.KafkaCluster.cluster
  lambda_function = module.LambdaFunction.lambda_function
}

module "LambdaFunction" {
  source = file("./modules/LambdaFunction/main.tf")
}