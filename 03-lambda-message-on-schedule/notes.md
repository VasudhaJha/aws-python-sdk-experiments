# Weekly Check: Log a Message on Fridays

## Question

Create a Lambda function that runs on a **schedule** (every 5 minutes), and:

- Checks if the current day is **Friday**
- If it's Monday → logs a greeting: `"It's Friday — weekend fun begins!"`
- Otherwise → exits silently (no log spam) to unnecessary logging in CloudWatch and simulate conditional automation.

---

## Tech Stack

- **Python 3.9 Lambda function**
- **CloudWatch EventBridge rule** (`rate(5 minutes)`)
- **IAM Role** with basic Lambda permissions (logs only)
- Deployed using: `boto3` + `zip` + `AWS CLI`

---

## What This Teaches

| Area | Covered |
|------|---------|
|  Scheduled Lambda | Using EventBridge trigger |
|  Lightweight IAM config with basic Lambda permissions (logs only) | No access to other AWS services needed |
|  CLI deployment experience | Zip + upload via CLI |

---

## Files in This Folder

| File | Purpose |
|------|---------|
| `lambda_function.py` | Main Lambda handler |
| `notes.md` | This documentation |
| `deploy.sh` (optional) | CLI commands to zip + deploy the function |
