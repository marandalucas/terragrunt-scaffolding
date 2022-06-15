terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-alb.git//.?ref=v6.10.0"
}

include {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

dependency "vpc" {
  config_path                             = "../../vpc/vpc-fargate/"
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
  mock_outputs = {
    vpc_id                      = "fake-vpc-id"
    private_subnets             = ["fake-private-subnet-1", "fake-private-subnet-2", "fake-private-subnet-3"]
    private_subnets_cidr_blocks = ["10.2.0.0/22", "10.2.4.0/22", "10.2.8.0/22"]
    public_subnets              = ["fake-public-subnet-1", "fake-public-subnet-2", "fake-public-subnet-3"]
    nat_public_ips              = ["10.2.28.0/25", "10.2.29.0/25", "10.2.30.0/25"]
  }
}

locals {
  purpose = "fargate"
  name    = format("%s-%s-%s-%s", include.locals.area_code, include.locals.account_name, include.locals.environment_short_name, local.purpose)
  tags = {
    Terraform   = "true"
    Area        = include.locals.area_code
    Account     = include.locals.account_name
    Environment = include.locals.environment_name
    Region      = include.locals.region_name
  }
}

inputs = {

  create_lb = true
  name   = local.name

  load_balancer_type = "application"

  vpc_id             = dependency.vpc.outputs.vpc_id
  subnets            = concat(dependency.vpc.outputs.private_subnets, dependency.vpc.outputs.public_subnets)

  security_groups    = [""] # TODO: Retrieve from dependency

  # access_logs = {
  #   bucket = "my-alb-logs" # TODO: Retrieve from dependency
  # }

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = {
        my_target = {
          target_id = "i-0123456789abcdefg"
          port = 80
        }
        my_other_target = {
          target_id = "i-a1b2c3d4e5f6g7h8i"
          port = 8080
        }
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012" # TODO: Retrieve from dependency
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = local.tags
}