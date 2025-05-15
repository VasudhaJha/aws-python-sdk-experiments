# Assume IAM Role and List S3 Buckets

## Question

How can an IAM user assume a role using `boto3` and perform an AWS operation (like listing S3 buckets) with the assumed role’s permissions?

---

## What This Teaches

- How to use AWS STS to assume an IAM role programmatically
- How to extract temporary credentials and use them to create a scoped `boto3.Session`
- The difference between trust policy (who *can* assume the role) vs IAM policy (who *is allowed* to)

---

## Setup Overview

### IAM Role (S3ReadOnlyAssumableRole)

1. Trust Policy: Trusts the IAM user to assume it.

```json
{
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::<account-id>:user/<user-name>"
  },
  "Action": "sts:AssumeRole"
}
```

1. Permissions Policy: Grants access to `s3:ListAllMyBuckets`, `s3:GetBucketLocation`

### IAM User

- Must have `sts:AssumeRole` permission for the target role.

```json
{
  "Effect": "Allow",
  "Action": "sts:AssumeRole",
  "Resource": "arn:aws:iam::<accountname>:role/S3ReadOnlyAssumableRole"
}
```

---

## Script Workflow

1. Use `boto3.client('sts')` to call `assume_role(...)`
1. Extract temporary credentials from the response
1. Create a `boto3.Session()` using those credentials
1. Use the session to create an `s3 client` and `list buckets`

---

## Error Handling

- Handles `NoCredentialsError` (if AWS CLI is not configured)
- Handles `ClientError` (for access denied, bad role ARN, etc.)

---

## Related Concepts

- Temporary credentials
- AWS STS
- boto3 sessions
- IAM trust vs permission policies
