resource "aws_iam_user" "this" {
  count = var.create_user ? 1 : 0

  name                 = var.name
  path                 = var.path
  force_destroy        = var.force_destroy
  permissions_boundary = var.permissions_boundary

  tags = var.tags
}

resource "aws_iam_user_login_profile" "this" {
  count = var.create_user && var.create_iam_user_login_profile ? 1 : 0

  user                    = aws_iam_user.this[0].name
  pgp_key                 = var.pgp_key
  password_length         = var.password_length
  password_reset_required = var.password_reset_required
}

resource "aws_iam_access_key" "this" {
  count = var.create_user && var.create_iam_access_key && var.pgp_key != "" ? var.access_key_count : 0

  user    = aws_iam_user.this[0].name
  pgp_key = var.pgp_key
  status  = var.iam_access_key_status
}

resource "aws_iam_access_key" "this_no_pgp" {
  count = var.create_user && var.create_iam_access_key && var.pgp_key == "" ? var.access_key_count : 0

  user   = aws_iam_user.this[0].name
  status = var.iam_access_key_status
}

resource "aws_iam_user_ssh_key" "this" {
  count = var.create_user && var.upload_iam_user_ssh_key ? 1 : 0

  username   = aws_iam_user.this[0].name
  encoding   = var.ssh_key_encoding
  public_key = var.ssh_public_key
}

resource "aws_iam_user_policy_attachment" "this" {
  for_each = { for k, v in var.policy_arns : k => v if var.create_user }

  user       = aws_iam_user.this[0].name
  policy_arn = each.value
}

####################################################################################

resource "aws_secretsmanager_secret" "this" {
  count = var.create_secret && length(var.secret_names) == var.access_key_count ? var.access_key_count : 0

  description                    = var.secret_description
  force_overwrite_replica_secret = var.force_overwrite_replica_secret
  kms_key_id                     = var.secret_kms_key_id
  name                           = var.secret_names[count.index]
  recovery_window_in_days        = var.recovery_window_in_days

  dynamic "replica" {
    for_each = var.secret_replica

    content {
      kms_key_id = try(secret_replica.value.kms_key_id, null)
      region     = try(secret_replica.value.region, replica.key)
    }
  }

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "this_no_pgp" {
  count = var.create_secret && var.pgp_key == "" && !(var.enable_secret_rotation || var.ignore_secret_changes) ? var.access_key_count : 0

  secret_id     = aws_secretsmanager_secret.this[count.index].id
  secret_string = jsonencode({
    access_key_id     = aws_iam_access_key.this_no_pgp[count.index].id
    secret_access_key = aws_iam_access_key.this_no_pgp[count.index].secret
  })
  secret_binary  = var.secret_binary
  version_stages = var.secret_version_stages
}

resource "aws_secretsmanager_secret_version" "ignore_changes" {
  count = var.create_secret && (var.enable_secret_rotation || var.ignore_secret_changes) ? var.access_key_count : 0

  secret_id     = aws_secretsmanager_secret.this[count.index].id
  secret_string = jsonencode({
    access_key_id     = aws_iam_access_key.this[count.index].id
    secret_access_key = aws_iam_access_key.this[count.index].secret
  })
  secret_binary  = var.secret_binary
  version_stages = var.secret_version_stages

  lifecycle {
    ignore_changes = [
      secret_string,
      secret_binary,
      version_stages,
    ]
  }
}
