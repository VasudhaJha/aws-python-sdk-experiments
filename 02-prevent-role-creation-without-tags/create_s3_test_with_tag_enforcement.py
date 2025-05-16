import boto3
import uuid
from botocore.exceptions import ClientError, NoCredentialsError

def assume_role(role_arn: str, session_name: str):
    """Assume the given IAM role and return a boto3 session."""
    try:
        sts_client = boto3.client('sts')
        response = sts_client.assume_role(RoleArn=role_arn, RoleSessionName=session_name)
        creds = response['Credentials']
        session = boto3.Session(
            aws_access_key_id=creds["AccessKeyId"],
            aws_secret_access_key=creds["SecretAccessKey"],
            aws_session_token=creds["SessionToken"]
        )
        return session
    except NoCredentialsError:
        print("AWS credentials not found. Did you run `aws configure`?")
        return None
    except ClientError as e:
        print(f"Error assuming role: {e.response['Error']['Code']} — {e.response['Error']['Message']}")
        return None

def create_s3_bucket(session: boto3.Session, with_tag: bool):
    s3 = session.client("s3")
    bucket_name = f"boto3-test-{uuid.uuid4().hex[:8]}"
    print(f"Attempting to create bucket: {bucket_name} {'(with tag)' if with_tag else '(without tag)'}")

    try:
        s3.create_bucket(
            Bucket=bucket_name,
            CreateBucketConfiguration={"LocationConstraint": "ap-south-1"}
        )
        print(f"Bucket created: {bucket_name}")

        if with_tag:
            s3.put_bucket_tagging(
                Bucket=bucket_name,
                Tagging={
                    "TagSet": [{"Key": "ManagedBy", "Value": "Python-Boto3"}]
                }
            )
            print("Tag applied: ManagedBy=Python-Boto3")

    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        message = e.response["Error"]["Message"]
        print(f"Error creating bucket {bucket_name}: Error code {error_code} — Error Message:{message}")


def main():
    role_arn = "arn:aws:iam::<account-id>:role/DenyUntaggedResourcesRole"

    session = assume_role(role_arn, session_name="DenyUntaggedResourcesTest")
    if session is None:
        print("Session is None")
        return

    print("\n--- Test 1: Create bucket WITH tag (should succeed) ---")
    create_s3_bucket(session, with_tag=True)

    print("\n--- Test 2: Create bucket WITHOUT tag (should be denied) ---")
    create_s3_bucket(session, with_tag=False)


if __name__ == "__main__":
    main()

