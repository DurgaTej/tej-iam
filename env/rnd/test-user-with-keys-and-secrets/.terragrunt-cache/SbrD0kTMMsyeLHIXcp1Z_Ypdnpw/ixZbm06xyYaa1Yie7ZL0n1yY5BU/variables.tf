variable "create_user" {
  description = "Whether to create the IAM user"
  type        = bool
  default     = true
}

variable "create_iam_user_login_profile" {
  description = "Whether to create IAM user login profile"
  type        = bool
  default     = false
}

variable "create_iam_access_key" {
  description = "Whether to create IAM access key"
  type        = bool
  default     = false
}

variable "name" {
  description = "Desired name for the IAM user"
  type        = string
}

variable "path" {
  description = "Desired path for the IAM user"
  type        = string
  default     = "/"
}

variable "force_destroy" {
  description = "When destroying this user, destroy even if it has non-Terraform-managed IAM access keys, login profile or MFA devices. Without force_destroy a user with non-Terraform-managed access keys and login profile will fail to be destroyed."
  type        = bool
  default     = false
}

variable "pgp_key" {
  description = "Either a base-64 encoded PGP public key, or a keybase username in the form `keybase:username`. Used to encrypt password and access key."
  type        = string
  default     = ""
}

variable "iam_access_key_status" {
  description = "Access key status to apply."
  type        = string
  default     = null
}

variable "password_reset_required" {
  description = "Whether the user should be forced to reset the generated password on first login."
  type        = bool
  default     = true
}

variable "password_length" {
  description = "The length of the generated password"
  type        = number
  default     = 20
}

variable "upload_iam_user_ssh_key" {
  description = "Whether to upload a public ssh key to the IAM user"
  type        = bool
  default     = false
}

variable "ssh_key_encoding" {
  description = "Specifies the public key encoding format to use in the response. To retrieve the public key in ssh-rsa format, use SSH. To retrieve the public key in PEM format, use PEM"
  type        = string
  default     = "SSH"
}

variable "ssh_public_key" {
  description = "The SSH public key. The public key must be encoded in ssh-rsa format or PEM format"
  type        = string
  default     = ""
}

variable "permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the user."
  type        = string
  default     = ""
}

variable "policy_arns" {
  description = "The list of ARNs of policies directly assigned to the IAM user"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "access_key_count" {
  description = "Number of Access Keys to be created"
  type = number
  default = 0
}


variable "create_secret" {
  description = "Whether to create the IAM user and secrets"
  type        = bool
  default     = false
}

variable "secret_name_prefix" {
  description = "Prefix for the AWS Secrets Manager secret name"
  type        = string
  default     = "myapp/iam-user"
}

variable "secret_description" {
  description = "Description for the secrets"
  type        = string
  default     = "Secret for IAM access keys"
}

variable "enable_secret_rotation" {
  description = "Whether to enable rotation for the secrets"
  type        = bool
  default     = false
}

variable "ignore_secret_changes" {
  description = "Whether to ignore secret changes"
  type        = bool
  default     = false
}

variable "force_overwrite_replica_secret" {
  description = "Whether to overwrite replica secrets"
  type        = bool
  default     = false
}

variable "secret_kms_key_id" {
  description = "The KMS key ID for encrypting secrets"
  type        = string
  default     = null
}

variable "secret_replica" {
  description = "List of replicas for multi-region secrets"
  type        = map(any)
  default     = {}
}

variable "secret_binary" {
  description = "Binary secret data"
  type        = string
  default     = null
}

variable "secret_version_stages" {
  description = "List of version stages"
  type        = list(string)
  default     = []
}

variable "recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before it can delete the secret. This value can be `0` to force deletion without recovery or range from `7` to `30` days. The default value is `30`"
  type        = number
  default     = null
}

variable "secret_names" {
  description = "Friendly name of the new secret. The secret name can consist of uppercase letters, lowercase letters, digits, and any of the following characters: `/_+=.@-`"
  type        = list(string)
  default     = null
}