resource "aws_eks_cluster" "gurleen_cluster" {
  name     = "gurleen-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.gurleen_subnet[*].id

    security_group_ids = [
      aws_security_group.gurleen_cluster_sg.id
    ]

    endpoint_public_access  = true
    endpoint_private_access = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name = "gurleen-eks-cluster"
  }
}

resource "aws_eks_node_group" "gurleen_nodes" {
  cluster_name = aws_eks_cluster.gurleen_cluster.name

  node_group_name = "gurleen-node-group"

  node_role_arn = aws_iam_role.eks_node_role.arn

  subnet_ids = aws_subnet.gurleen_subnet[*].id

  instance_types = [var.instance_type]

  capacity_type = "SPOT"

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 2
  }

  remote_access {
    ec2_ssh_key               = var.key_name
    source_security_group_ids = [aws_security_group.gurleen_node_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_policy
  ]

  tags = {
    Name = "gurleen-eks-worker-node"
  }
}

# ============================================================
# EBS CSI DRIVER ADDON
# ============================================================

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.gurleen_cluster.name
  addon_name   = "aws-ebs-csi-driver"

  service_account_role_arn = aws_iam_role.ebs_csi_role.arn

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_policy,
    aws_eks_node_group.gurleen_nodes
  ]
}

resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = "gurleen-eks-cluster"
  principal_arn = aws_iam_role.github_actions_ecr.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions" {
  cluster_name  = "gurleen-eks-cluster"
  principal_arn = aws_iam_role.github_actions_ecr.arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}