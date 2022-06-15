terraform {
  source = "github.com/marandalucas/terraform-aws-ecs.git//.?ref=v0.1.0"
}

include {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

locals {
  purpose = "fargate"
  name    = format("%s-%s-%s-%s-vpc-%s", include.locals.area_code, include.locals.account_name, include.locals.environment_name, include.locals.region_name, local.purpose)
}
inputs = {

  create = true
  name   = local.name

  tags = {
    Terraform   = "true"
    Area        = include.locals.area_code
    Account     = include.locals.account_name
    Environment = include.locals.environment_name
    Region      = include.locals.region_name
  }
}