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
  description = "ClickHouse cluster name"
}

variable "eks_cluster" {
  type = object({
    id           = string
    node_group_name = string
  })
  description = "EKS cluster object"
}

resource "aws_eks_addon" "this" {
  cluster_name = var.eks_cluster.id
  addon_name   = "ClickHouse-operator"
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = "ClickHouse"
  }
  depends_on = [aws_eks_addon.this]
}

resource "helm_release" "this" {
  name       = "ClickHouse"
  chart      = "clickhouse/clickhouse"
  namespace = kubernetes_namespace.this.metadata[0].name
  version    = "2.5.0"
  depends_on = [aws_eks_addon.this]
}

output "ClickHouseCluster" {
  value = {
    namespace = kubernetes_namespace.this.metadata[0].name
    release   = helm_release.this
  }
}