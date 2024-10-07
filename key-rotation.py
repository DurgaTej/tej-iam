import boto3
import os
import datetime
import json

# Environment variables for IAM user, secret names, and role ARN
IAM_USER = os.environ['IAM_USER']
SECRET_KEY1 = os.environ['SECRET_KEY1']
SECRET_KEY2 = os.environ['SECRET_KEY2']
ROLE_ARN = os.environ['ROLE_ARN']

def assume_role(role_arn):
    sts_client = boto3.client('sts')
    assumed_role = sts_client.assume_role(
        RoleArn=role_arn,
        RoleSessionName='KeyRotationSession'
    )
    credentials = assumed_role['Credentials']
    return boto3.client(
        'iam',
        aws_access_key_id=credentials['AccessKeyId'],
        aws_secret_access_key=credentials['SecretAccessKey'],
        aws_session_token=credentials['SessionToken']
    ), boto3.client(
        'secretsmanager',
        aws_access_key_id=credentials['AccessKeyId'],
        aws_secret_access_key=credentials['SecretAccessKey'],
        aws_session_token=credentials['SessionToken']
    )

def get_current_access_key_from_secret(secrets_client, secret_name):
    # Retrieve the secret value from AWS Secrets Manager
    response = secrets_client.get_secret_value(SecretId=secret_name)
    secret_value = response['SecretString']
    print(f"Secret value retrieved: {secret_value}")

    # Parse the secret value to get the access key ID
    secret_data = json.loads(secret_value)
    current_access_key = secret_data['access_key_id']

    return current_access_key

def rotate_key(iam_client, secrets_client, secret_name):
    # Get the current access key from the secret to identify which key to delete
    key_to_delete = get_current_access_key_from_secret(secrets_client, secret_name)

    # Delete the old access key
    iam_client.delete_access_key(UserName=IAM_USER, AccessKeyId=key_to_delete)

    # Create a new access key
    response = iam_client.create_access_key(UserName=IAM_USER)
    new_access_key = response['AccessKey']['AccessKeyId']
    new_secret_key = response['AccessKey']['SecretAccessKey']

    # Update the secret in AWS Secrets Manager with the new access key and secret key
    new_secret_data = json.dumps({
        'access_key_id': new_access_key,
        'secret_access_key': new_secret_key
    })

    secrets_client.update_secret(
        SecretId=secret_name,
        SecretString=new_secret_data
    )

    # Test the new key's access (implement your testing logic here)

    # Delete the old access key
    # iam_client.delete_access_key(UserName=IAM_USER, AccessKeyId=key_to_delete)

def lambda_handler():
    # Assume the role to get IAM and Secrets Manager clients with assumed role permissions
    iam_client, secrets_client = assume_role(ROLE_ARN)

    current_day = datetime.datetime.now().day

    if current_day == 1:
        # Rotate Key 1
        rotate_key(iam_client, secrets_client, secret_name=SECRET_KEY1)
    elif current_day == 15:
        # Rotate Key 2
        rotate_key(iam_client, secrets_client, secret_name=SECRET_KEY2)

    return {"statusCode": 200, "body": "Key rotation successful"}

lambda_handler()
