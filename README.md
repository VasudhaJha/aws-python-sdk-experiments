# AWS Python SDK Experiments

This repository contains my hands-on experiments and mini-projects using the [AWS SDK for Python (`boto3`)](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html). The goal is to understand AWS services deeply by interacting with them programmatically through Python.

Each folder is a small, focused project that explores one AWS use case or concept.

---

## Topics Covered

| Folder | Description |
|--------|-------------|
| `00-setup` | Setting up AWS CLI and credentials |
| `01-assume-role` | Assume role to list `S3` buckets using `boto3` |
| `02-ec2-snapshot-lambda` | Auto-snapshot EC2 on launch using Lambda |
| `03-s3-ops` | Upload/download files to S3 buckets |
| `04-iam-roles` | Creating and assuming IAM roles via Python |
| More coming... | Notifications, CloudWatch Logs, DynamoDB, etc. |

---

## How to Use

1. Clone the repo:

   ```bash
   git clone https://github.com/vasudhajha/aws-python-sdk-experiments.git
   cd aws-python-sdk-experiments
   ```
