provider "aws" {
  region = var.region
}

variable "region" {
  type        = string
  default     = "us-west-2"
  description = "AWS region"
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = [aws_subnet.eks_subnet.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
  ]
}

variable "cluster_name" {
  type        = string
  default     = "example"
  description = "EKS cluster name"
}

resource "aws_iam_role" "eks_cluster" {
  name        = var.iam_role_name
  description = "EKS cluster role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
}

variable "iam_role_name" {
  type        = string
  default     = "eks-cluster-role"
  description = "IAM role name for EKS cluster"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_subnet" "eks_subnet" {
  cidr_block = var.subnet_cidr_block
  vpc_id     = aws_vpc.eks_vpc.id
  availability_zone = var.region
}

variable "subnet_cidr_block" {
  type        = string
  default     = "10.0.1.0/24"
  description = "Subnet CIDR block for EKS cluster"
}

resource "aws_vpc" "eks_vpc" {
  cidr_block = var.vpc_cidr_block
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR block for EKS cluster"
}

output "EKS" {
  value = aws_eks_cluster.this
}