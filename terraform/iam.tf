# ============================================================
# EKS CLUSTER IAM ROLE
# ============================================================

resource "aws_iam_role" "eks_cluster_role" {
  name = "gurleen-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "eks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "gurleen-eks-cluster-role"
  }
}


# EKS Cluster Policy
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


# ============================================================
# EKS NODE GROUP IAM ROLE
# ============================================================

resource "aws_iam_role" "eks_node_role" {
  name = "gurleen-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "gurleen-eks-node-role"
  }
}


# Worker Node Policy
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


# EKS CNI Policy
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


# ECR Pull Policy
resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

# ============================================================
# EKS OIDC PROVIDER
# ============================================================

data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.gurleen_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint
  ]

  url = aws_eks_cluster.gurleen_cluster.identity[0].oidc[0].issuer

  tags = {
    Name = "gurleen-eks-oidc"
  }
}

# ============================================================
# EBS CSI DRIVER IAM ROLE
# ============================================================

data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_role" {
  name = "gurleen-ebs-csi-role"

  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json

  tags = {
    Name = "gurleen-ebs-csi-role"
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# ============================================================
# AWS LOAD BALANCER CONTROLLER IAM
# ============================================================

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name = "AWSLoadBalancerControllerIAMPolicy"

  policy = file("${path.module}/aws-load-balancer-controller-policy.json")
}

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.eks.arn
      ]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test = "StringEquals"

      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test = "StringEquals"

      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"

      values = [
        "system:serviceaccount:kube-system:aws-load-balancer-controller"
      ]
    }
  }
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  name = "gurleen-aws-load-balancer-controller-role"

  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role.json

  tags = {
    Name = "gurleen-aws-load-balancer-controller-role"
  }
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role = aws_iam_role.aws_load_balancer_controller.name

  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}