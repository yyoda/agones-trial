variable profile {}
variable region {
  default = "ap-northeast-1"
}

provider aws {
  profile = var.profile
  region  = var.region
}

locals {
  namespace = "yoda"
  env       = "trial"

  tags = {
    namespace = local.namespace
    env       = local.env
  }
}

module network {
  source            = "../modules/network"
  prefix            = "${local.env}-${local.namespace}-"
  cidr              = "10.140.0.0/16"
  private_zone_name = "${local.env}-${local.namespace}.local"

  subnets = {
    public = {
      "ap-northeast-1a" = "10.140.0.0/21"
      "ap-northeast-1c" = "10.140.8.0/21"
    }
    private = {
      "ap-northeast-1a" = "10.140.128.0/21"
      "ap-northeast-1c" = "10.140.136.0/21"
    }
  }

  tags = local.tags
}

module eks {
  source          = "git::github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v12.2.0"
  cluster_name    = "${local.env}-${local.namespace}"
  subnets         = [for subnet in module.network.subnets.public : subnet.id]
  cluster_version = "1.17"
  vpc_id          = module.network.vpc.id

  worker_groups_launch_template = concat(
    [
      {
        name                          = "default"
        instance_type                 = "t2.micro"
        asg_desired_capacity          = 4
        asg_min_size                  = 4
        asg_max_size                  = 4
        additional_security_group_ids = [module.network.security_groups.eks.worker_group_mgmt_one.id]
        public_ip                     = true
      }
    ],
    [
      for name in toset(["agones-system", "agones-metrics"]) :
      {
        name                 = name
        instance_type        = "t2.micro"
        asg_desired_capacity = 1
        kubelet_extra_args   = "--node-labels=agones.dev/agones-system=true --register-with-taints=agones.dev/agones-system=true:NoExecute"
        public_ip            = true
      }
  ])
}

data aws_eks_cluster_auth default {
  name = "${local.env}-${local.namespace}"
}

provider "helm" {
  version = "~> 1.2"
  kubernetes {
    load_config_file       = false
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.default.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}

module helm {
  source = "../modules/helm3"
}
