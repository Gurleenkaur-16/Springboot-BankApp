resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}
data "aws_iam_policy_document" "github_actions_assume_role" {
  # Statement 1: Allow GitHub Actions to assume the IAM role
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test = "StringEquals"

      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test = "StringEquals"

      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:Gurleenkaur-16/Springboot-BankApp:ref:refs/heads/DevOps"
      ]
    }
  }
}


resource "aws_iam_role" "github_actions_ecr" {
  name = "github-actions-bankapp-ecr"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}
data "aws_iam_policy_document" "github_actions_ecr" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = [
      "arn:aws:ecr:eu-west-1:747938282480:repository/bankapp-backend"
    ]
  }
  # Statement 2: Allow GitHub Actions to describe the EKS cluster
  statement {
    effect = "Allow"

    actions = [
      "eks:DescribeCluster"
    ]

    resources = [
      "arn:aws:eks:eu-west-1:747938282480:cluster/gurleen-eks-cluster"
    ]
  }
}
resource "aws_iam_role_policy" "github_actions_ecr" {
  role = aws_iam_role.github_actions_ecr.id

  policy = data.aws_iam_policy_document.github_actions_ecr.json
}