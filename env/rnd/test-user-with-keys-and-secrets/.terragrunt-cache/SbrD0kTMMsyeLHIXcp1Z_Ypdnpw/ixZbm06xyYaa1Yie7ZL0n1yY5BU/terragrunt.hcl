include {
    path = find_in_parent_folders()
}

terraform {
    source = "/Users/durgatej/development/terraform/terraform-aws-iam/modules/iam_user_with_keys_and_secrets"
}