import boto3
from botocore.exceptions import ClientError, NoCredentialsError

# the arn of the role you want to assume
role_arn = "arn:aws:iam::<account-id>:role/<role-to-assume>"

# Session name for STS logs — just a unique string
session_name = "AssumeRoleS3Session"

try:
    # 1. Create a base boto3 STS client (uses default credentials/profile)
    sts_client = boto3.client('sts')
    response = sts_client.assume_role(RoleArn=role_arn, RoleSessionName=session_name)

    temp_credentials = response['Credentials']
except NoCredentialsError:
    print("AWS credentials not found. Did you run `aws configure`?")
except ClientError as e:
    print(f"Error assuming role: {e.response['Error']['Code']} — {e.response['Error']['Message']}")

# 3. Create a new boto3 session with the temporary credentials
assumed_session = boto3.Session(
    aws_access_key_id=temp_credentials['AccessKeyId'],
    aws_secret_access_key=temp_credentials['SecretAccessKey'],
    aws_session_token=temp_credentials['SessionToken']
)

# 4. Use the new session to create an S3 client
s3_client = assumed_session.client('s3')

# 4. List all S3 buckets
response = s3_client.list_buckets()

print("Buckets accessible with assumed role:")
for bucket in response['Buckets']:
    print(f" - {bucket['Name']} (Created: {bucket['CreationDate']})")

# Optional: Show token expiration
expires = temp_credentials['Expiration']
print(f"\nTemporary credentials expire at: {expires}")