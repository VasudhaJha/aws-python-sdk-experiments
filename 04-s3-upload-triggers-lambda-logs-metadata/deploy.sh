#!/bin/bash

# Configuration
FUNCTION_NAME="s3-upload-triggers-lambda-logs-metadata"
ROLE_NAME="LambdaMetadataLoggerFromS3Role"
ROLE_ARN=""
POLICY_NAME="S3MetadataReadAndLog"
ZIP_FILE="function.zip"
HANDLER="lambda_function.lambda_handler"
RUNTIME="python3.9"
REGION="ap-south-1"
BUCKET_NAME="testbucketvj12345"
STATEMENT_ID="AllowS3InvokeLambda"
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Step 1: Ensure role exists
echo "Checking for IAM role: $ROLE_NAME"
if ! aws iam get-role --role-name $ROLE_NAME --region $REGION &> /dev/null; then
  echo "Role not found. Creating..."
  aws iam create-role \
    --role-name $ROLE_NAME \
    --assume-role-policy-document file://trust-policy.json \
    --region $REGION

  echo "Attaching policy: $POLICY_NAME"
  aws iam put-role-policy \
  --role-name $ROLE_NAME \
  --policy-name $POLICY_NAME \
  --policy-document file://permissions-policy.json

  echo "Waiting 10 seconds for IAM role propagation..."
  sleep 10
else
  echo "IAM role exists."
fi

# Step 2: Get the Role ARN
ROLE_ARN=$(aws iam get-role --role-name $ROLE_NAME --region $REGION --query 'Role.Arn' --output text)

# Step 3: Package the Lambda function
echo "Zipping source..."
zip -q $ZIP_FILE lambda_function.py

# Step 4: Check if function exists
echo "Checking if function exists..."
if aws lambda get-function --function-name $FUNCTION_NAME --region $REGION &> /dev/null; then
    echo "Function exists. Updating code..."
    aws lambda update-function-code \
        --function-name $FUNCTION_NAME \
        --zip-file fileb://$ZIP_FILE \
        --region $REGION
else
    echo "Function doesn't exist. Creating it..."
    aws lambda create-function \
        --function-name $FUNCTION_NAME \
        --runtime $RUNTIME \
        --handler $HANDLER \
        --role "$ROLE_ARN" \
        --zip-file fileb://$ZIP_FILE \
        --region $REGION
fi

# Step 5: Allow S3 to invoke the Lambda
echo "Checking for Permission: $STATEMENT_ID"
aws lambda add-permission \
  --function-name $FUNCTION_NAME \
  --statement-id $STATEMENT_ID \
  --action lambda:InvokeFunction \
  --principal s3.amazonaws.com \
  --source-arn arn:aws:s3:::$BUCKET_NAME \
  --region $REGION \
  2>/dev/null || echo "Permission already exists or was skipped"

# Step 6: Configure the S3 bucket to trigger the Lambda
aws s3api put-bucket-notification-configuration \
  --bucket $BUCKET_NAME \
  --notification-configuration "{
    \"LambdaFunctionConfigurations\": [
      {
        \"LambdaFunctionArn\": \"arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$FUNCTION_NAME\",
        \"Events\": [\"s3:ObjectCreated:*\"]
      }
    ]
  }"


