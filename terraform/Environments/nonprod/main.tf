provider "aws" {
  profile = var.profile
  region  = var.region
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}"]
  }
}

data "aws_subnet_ids" "eks_subnets" {
  vpc_id = data.aws_vpc.selected.id

  filter {
    name   = "tag:kubernetes.io/cluster/eks"
    values = ["shared"] # insert values here
  }
  depends_on = [data.aws_vpc.selected]
}


data "aws_region" "current" {}

data "aws_eks_cluster" "target" {
  name = "nonprod-eks-cluster"
  depends_on = [module.eks_cluster]
}

data "aws_eks_cluster_auth" "aws_iam_authenticator" {
  name = data.aws_eks_cluster.target.name
  depends_on = [module.eks_cluster]
}

provider "kubernetes" {
  alias = "eks"
  host                   = data.aws_eks_cluster.target.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.target.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.aws_iam_authenticator.token
}

module "alb_ingress_controller" {
  source  = "../../modules/aws/alb_ingress_controller"
 
  providers = {
    kubernetes = kubernetes.eks
  } 

  k8s_cluster_type = "eks"
  k8s_namespace    = "kube-system"

  aws_region_name  = var.region
  k8s_cluster_name = data.aws_eks_cluster.target.name
  depends_on = [module.eks_cluster]
}


module "eks_cluster" {
  source = "../../modules/aws/eks_cluster"
  cluster_name    = "${var.cluster_name}"
  cluster_version = "${var.cluster_version}"
  subnet_ids  = data.aws_subnet_ids.eks_subnets.ids
  vpc_id          = data.aws_vpc.selected.id
}


resource "aws_iam_role" "main" {
  name = "eks-managed-group-node-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "main_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.main.name
}

resource "aws_iam_role_policy_attachment" "main_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.main.name
}

resource "aws_iam_role_policy_attachment" "main_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.main.name
}

module "eks-node-group" {
 // for_each =  toset(data.aws_subnet_ids.eks_subnets.ids)
  source = "umotif-public/eks-node-group/aws"
  version = "~> 3.0.0"
  cluster_name = data.aws_eks_cluster.target.id
  subnet_ids = data.aws_subnet_ids.eks_subnets.ids

  
  max_size     = var.max_size
  min_size     = var.min_size
  desired_size = var.desired_size
  disk_size    = 100

  instance_types = ["t3.xlarge"]

  ec2_ssh_key = var.key_name

  kubernetes_labels = {
    lifecycle = "spot"
  }

  force_update_version = true

  tags = {
    Environment = "spot"
  }
}
