Here is a better implementation for the file:

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
  description = "Kafka cluster name"
}

variable "eks_cluster" {
  type = object({
    id           = string
  })
  description = "EKS cluster object"
}

variable "clickhouse_cluster" {
  type = object({
    namespace = string
  })
  description = "ClickHouse cluster object"
}

resource "kubernetes_namespace" "kafka" {
  metadata {
    name = "kafka"
  }
  depends_on = [module.EKS.EKS]
}

resource "kafka_cluster" "kafka" {
  namespace = kubernetes_namespace.kafka.metadata[0].name
  depends_on = [module.EKS.EKS, module.ClickHouseCluster.ClickHouseCluster]
}

resource "kafka_topic" "events" {
  name         = "events"
  namespace    = kubernetes_namespace.kafka.metadata[0].name
  partitions   = 3
  replication_factor = 2
  depends_on = [kafka_cluster.kafka]
}

output "namespace" {
  value = kubernetes_namespace.kafka.metadata[0].name
}

output "cluster" {
  value = kafka_cluster.kafka
}

output "topic" {
  value = kafka_topic.events
}