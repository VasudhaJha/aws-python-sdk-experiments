# AWS SDK + CLI Setup Notes

## access-key-id and secret-access-key based setup

This guide documents the environment setup required to run boto3-based AWS automation scripts.

---

### Prerequisites

- Python 3.9 or higher
- AWS CLI installed
- A personal or sandbox AWS account
- IAM user with programmatic access

---

### Step-by-Step Setup

#### 1. Install AWS CLI

```bash
# On macOS
brew install awscli

# On Ubuntu/Debian
sudo apt install awscli

# Check version
aws --version
```

#### 2. Configure AWS Credentials

```bash
aws configure
```

You'll be prompted for:

1. AWS Access Key ID

1. AWS Secret Access Key

1. Default Region (e.g. us-east-1)

1. Output Format (e.g. json)

Files created:

1. `~/.aws/credentials`: For secrets (access keys, tokens), no profile prefix in section headers.

1. `~/.aws/config`: For general settings (region, output), use profile prefix for named profiles.

Credentials in the credentials file override those in the config file if both are present for a profile.

#### 3. Create IAM User (if not done)

From AWS Console:

- Go to **IAM → Users → Add user**
- Enable **Programmatic** Access
- Save Access + Secret Keys securely

#### 4. Set up Python Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate
```

Create a `requirements.txt`

```text
boto3
```

Run `pip install -r requirements.txt`

#### 5. Test your Setup

Test your setup:

```bash
aws sts get-caller-identity
```

This will confirm that your credentials are working.

You are now ready to:

- Authenticate with AWS from Python
- Use boto3 to interact with services like EC2, S3, IAM, etc.

## IAM Role Based Setup

This setup is recommended for production workloads running on AWS-managed services like EC2, Lambda, or ECS, where you want secure, temporary credential access without hardcoding secrets.

### Step-by-Step Setup (EC2 Example)

#### 1. Create an IAM Role (the one to assume)

- Go to IAM → Roles → Create Role
- Trusted entity type: "Another AWS account or user"
- Set the trust policy to:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<ACCOUNT_ID>:user/<IAM_USER_NAME>"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

- Attach a permissions policy (e.g. allow S3 read access)
- Name the role (e.g. S3ReadOnlyAssumableRole)

#### 2. Grant the IAM User Permission to Assume the Role

Attach an inline or managed policy to the IAM user:

```json
{
  "Effect": "Allow",
  "Action": "sts:AssumeRole",
  "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/S3ReadOnlyAssumableRole"
}
```

#### 3. Python Script to Assume the Role and Use It

```python
import boto3

sts_client = boto3.client("sts")

response = sts_client.assume_role(
    RoleArn="arn:aws:iam::<ACCOUNT_ID>:role/S3ReadOnlyAssumableRole",
    RoleSessionName="MySession"
)

creds = response["Credentials"]

assumed_session = boto3.Session(
    aws_access_key_id=creds["AccessKeyId"],
    aws_secret_access_key=creds["SecretAccessKey"],
    aws_session_token=creds["SessionToken"]
)

s3 = assumed_session.client("s3")
for bucket in s3.list_buckets()["Buckets"]:
    print(bucket["Name"])
```

- These credentials last 1 hour by default (can be configured)
- You can assume roles across accounts by changing the trust policy principal
- This pattern is often used in automation where roles are assumed for scoped permissions
