
locals {
  global      = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  area        = read_terragrunt_config(find_in_parent_folders("area.hcl"))
  account     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  region      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Need to define all the variables present inside the files to make it available for usage in internal terragrunt folders using "include"
  area_code                   = local.area.locals.area_code
  account_id                  = local.account.locals.account_id
  account_name                = local.account.locals.account_name
  environment_name            = local.environment.locals.environment_name
  environment_short_name      = local.environment.locals.environment_short_name
  region_name                 = local.region.locals.region_name
  region_short_name           = local.region.locals.region_short_name
  aws_region_terragrunt_state = local.global.locals.aws_region_terragrunt_state
}

# Get all the global variables that to pass them by default to all the terragrunt modules as inputs.
inputs = merge(
  local.global.locals,
  local.area.locals,
  local.account.locals,
  local.environment.locals,
  local.region.locals,
)

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region     = "${local.region_name}"
      allowed_account_ids = ["${local.account_id}"]
      assume_role {
        role_arn = "${local.account.locals.provider_assume_role_arn}"
      }
    }
  EOF
}

# Remote state handler. If the bucket exist it won't create it.
# Can be overwritten in child terragrunt.hcl
remote_state {
  backend = "s3"

  config = {
    bucket = format("%s-%s-%s-state",
      local.area_code,
      local.account_name,
      local.account_id
    )
    key    = "${path_relative_to_include()}/terraform.tfstate"
    region = local.aws_region_terragrunt_state
    dynamodb_table = format("%s-%s-%s-locks",
      local.area_code,
      local.account_name,
      local.account_id,
    )
    encrypt = true
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

terraform {

  extra_arguments "reduced_parallelism" {
    commands  = get_terraform_commands_that_need_parallelism()
    arguments = ["-parallelism=2"]
  }

  before_hook "auto_init" {
    commands = ["validate", "plan", "apply", "destroy", "workspace", "output", "import"]
    execute  = ["terraform", "init"]
  }

  before_hook "before_hook" {
    commands = ["plan", "apply"]
    execute  = ["echo", "Before Hook Action"]
  }

  after_hook "after_hook" {
    commands     = ["apply"]
    execute      = ["echo", "After Hook Action!"]
    run_on_error = false
  }
}
