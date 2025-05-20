resource "aws_key_pair" "eks" {
  key_name   = "expense-eks"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDAwrcfiQKv9v5spMRPVt0KiP+1LL2F10v3KfOC0P/9GchUoYQIeUVBSCMYBbcQdXp0dueCvo0/Jnu8VoPY6JNxjMp8KPcFPSD820/byrLX+nZSvBUyob+VjTVzaCn7B0bDNGszOfwMN9muq/CTMcMxQOIJ4jFecOgt7SgZbbNh7g6/2q5SJOuFiWZkqgsxvbAytVA3/FL0v5UU+Ba7Kh1Ugu1skQNDClvpZg+NzHHQNP6E4EWAtZSQUflPS83qtvJPF6cXj9bFb7h5kG+i2qWsB6+iujC+964XWImGr8ftVOpe6JWxRcg+C++bTJgz4sdWxCBbo/KtpzjLzVtvOpAI10V9Y+KGkPQuEVYty9Wk1HzLb13TS+iWbXXdrW0eadFl5nGsyrvE1Yen+Tae7J6ayRmjrfYw6Dio1rAmTW1Sms+Df4cESzpVsjEALfoqJmNxDJy6SLpZXQiNXhdeIAxkotnedo0fEHbsx15nx/0EJT9bHCfyh/l6g+l+4O2mjOE= user@AshDexter-T480"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = "1.32" # later we upgrade 1.32
  create_node_security_group = false
  create_cluster_security_group = false
  cluster_security_group_id = local.eks_control_plane_sg_id
  node_security_group_id = local.eks_node_sg_id

  #bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    metrics-server = {}
  }

  # Optional
  cluster_endpoint_public_access = false

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    /* blue = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      #ami_type       = "AL2_x86_64"
      instance_types = ["m5.xlarge"]
      key_name = aws_key_pair.eks.key_name

      min_size     = 2
      max_size     = 10
      desired_size = 2
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
    } */

    green = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      #ami_type       = "AL2_x86_64"
      instance_types = ["m5.xlarge"]
      key_name = aws_key_pair.eks.key_name

      min_size     = 2
      max_size     = 10
      desired_size = 2
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
    }
  }

  tags = merge(
    var.common_tags,
    {
        Name = local.name
    }
  )
}