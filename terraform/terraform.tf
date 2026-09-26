terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.64.0"
    }

    tls = {
      source = "hashicorp/tls"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "kubernetes" {
  host                   = aws_eks_cluster.gurleen_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.gurleen_cluster.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"

    args = [
      "eks",
      "get-token",
      "--cluster-name",
      aws_eks_cluster.gurleen_cluster.name,
      "--region",
      "eu-west-1"
    ]
  }
}

provider "helm" {
  kubernetes = {
    host                   = aws_eks_cluster.gurleen_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.gurleen_cluster.certificate_authority[0].data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"

      args = [
        "eks",
        "get-token",
        "--cluster-name",
        aws_eks_cluster.gurleen_cluster.name,
        "--region",
        "eu-west-1"
      ]
    }
  }
}