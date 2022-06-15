terraform {
  source = "github.com/marandalucas/terraform-aws-vpc.git//.?ref=v0.1.0"
}

include {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

locals {
  purpose = "fargate"
  name    = format("%s-%s-%s-%s-vpc-%s", include.locals.area_code, include.locals.account_name, include.locals.environment_short_name, include.locals.region_name, local.purpose)
}
inputs = {

  create = true
  name   = local.name

  # 8190 reserved Host/Nets.
  # HostMin 10.2.0.1 to HostMax 10.2.31.254
  cidr = "10.2.0.0/19"
  # 1022 reserved Host/Net by subnets.
  # HostMin 10.2.0.1 to HostMax 10.2.11.254
  private_subnets = ["10.2.0.0/22", "10.2.4.0/22", "10.2.8.0/22"]
   # 126 reserved Host/Net by subnets.
  public_subnets  = ["10.2.28.0/25", "10.2.29.0/25", "10.2.30.0/25"]

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  ## Single NAT Gateway
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  map_public_ip_on_launch = false

  ## Internet Gateway
  create_igw = true

  ## Other properties
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = false


  tags = {
    Terraform   = "true"
    Area        = include.locals.area_code
    Account     = include.locals.account_name
    Environment = include.locals.environment_name
    Region      = include.locals.region_name
  }
}