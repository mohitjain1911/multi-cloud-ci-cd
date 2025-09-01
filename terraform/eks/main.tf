module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1"

  name = "flask-task-manager-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Project = "flask-task-manager"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets

  # ✅ Ensure the EKS API is reachable from your machine
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  eks_managed_node_groups = {
    flask_nodes = {
      min_size       = var.min_capacity
      max_size       = var.max_capacity
      desired_size   = var.desired_capacity
      instance_types = [var.instance_type]
    }
  }

  tags = {
    Project = "flask-task-manager"
  }
}

