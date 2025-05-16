# Log S3 File Metadata on Upload

## Question

Create a Lambda function that is triggered **automatically when a file is uploaded to an S3 bucket**. The function:

- Extracts the uploaded object's:
  - Bucket name
  - Key (path)
  - Size
  - Content type
  - Last modified timestamp
  - Custom user metadata (if any)
- Logs all this info as **structured JSON** to **CloudWatch Logs**

This simulates a real-world pipeline where file uploads are **monitored**, **audited**, or used to **trigger downstream processing**.

---

## Tech Stack

- **S3** bucket with event notification
- **Lambda** function written in Python
- **Trigger type**: `s3:ObjectCreated:*`
- **IAM Role** with:
  - `s3:GetObject` and `s3:HeadObject` permissions
  - `logs:*` permissions for CloudWatch
- **Deployed using:** `boto3` and `AWS CLI`

---

## What This Teaches

| Area | Covered |
|------|---------|
| S3 triggers | Hook Lambda to run automatically on object uploads |
| Event parsing | Understand and extract from `event['Records']` |
| S3 metadata access | Use `head_object()` to get rich metadata |
| Structured logging | Emit JSON logs into CloudWatch |
| IAM scoping | Least-privilege Lambda execution role |
| Deployment | Automate via CLI (`deploy.sh`) and role setup |

---

## Files in This Folder

| File | Purpose |
|------|---------|
| `lambda_function.py` | Main Lambda code — loops through uploaded files and logs metadata |
| `deploy.sh` | Automates role creation for lambda, zips lambda function and uploads it using AWS CLI |
| `notes.md` | This documentation |
