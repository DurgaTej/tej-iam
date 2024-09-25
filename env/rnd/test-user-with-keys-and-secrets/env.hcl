locals {
    create_user = true
    access_key_count = 2
    create_iam_access_key = true
    create_iam_user_login_profile = false

    name = "rnd-vendor-ui-path-firm-management"

    create_secret = true
    ignore_secret_changes = true
    secret_names = [
        "/ABC/external/rnd/ui-path/firm-management/aws_api_key1",
        "/ABC/external/rnd/ui-path/firm-management/aws_api_key2"
    ]
}
