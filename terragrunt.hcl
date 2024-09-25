locals {
    account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl","account.hcl"))
    environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl","env.hcl"))

    aws_account = local.account_vars.locals.aws_account
    aws_subaccount = local.account_vars.locals.aws_subaccount
    aws_role = local.account_vars.locals.aws_role
    aws_region = local.account_vars.locals.aws_region

    env = local.environment_vars.locals
}

remote_state {
    backend = "local"
    config = {
        path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/terraform.tfstate"
    }

    generate = {
        path = "backend.tf"
        if_exists = "overwrite"
    }
}

generate "provider" {
    path = "provider.tf"
    if_exists = "overwrite_terragrunt"
    contents = <<EOF
    provider "aws" {
        alias = "main"
        region = "${local.aws_region}"
    }
    provider "local" {

    }
    EOF
}

inputs = merge (
    local.account_vars.locals,
    local.environment_vars.locals
)

