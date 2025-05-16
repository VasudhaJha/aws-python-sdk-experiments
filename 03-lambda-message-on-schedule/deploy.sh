#!/bin/bash

# Configuration
FUNCTION_NAME="weekly-check-friday-greeting"
ROLE_NAME="LambdaWeeklyLoggerRole"
ROLE_ARN=""
POLICY_ARN="arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
ZIP_FILE="function.zip"
HANDLER="lambda_function.lambda_handler"
RUNTIME="python3.9"
REGION="ap-south-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Step 1: Ensure role exists
echo "Checking for IAM role: $ROLE_NAME"
if ! aws iam get-role --role-name $ROLE_NAME --region $REGION &> /dev/null; then
  echo "Role not found. Creating..."
  aws iam create-role \
    --role-name $ROLE_NAME \
    --assume-role-policy-document file://trust-policy.json \
    --region $REGION

  echo "Attaching policy: $POLICY_ARN"
  aws iam attach-role-policy \
    --role-name $ROLE_NAME \
    --policy-arn $POLICY_ARN \
    --region $REGION

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

# Step 5: Create CloudWatch EventBridge rule
RULE_NAME="TriggerLambdaEvery5Minutes"
SCHEDULE_EXPRESSION="rate(5 minutes)"

echo "Ensuring EventBridge rule: $RULE_NAME"
if ! aws events describe-rule --name $RULE_NAME --region $REGION &> /dev/null; then
  aws events put-rule \
    --name $RULE_NAME \
    --schedule-expression "$SCHEDULE_EXPRESSION" \
    --region $REGION
  echo "Created rule $RULE_NAME"
else
  echo "Rule $RULE_NAME already exists"
fi

# Step 6: Add Lambda function as target to the rule
aws events put-targets \
  --rule $RULE_NAME \
  --targets "Id"="1","Arn"="arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$FUNCTION_NAME" \
  --region $REGION

# Step 7: Grant permission to EventBridge to invoke Lambda
aws lambda add-permission \
  --function-name $FUNCTION_NAME \
  --statement-id "AllowExecutionFromEventBridge-$RULE_NAME" \
  --action 'lambda:InvokeFunction' \
  --principal events.amazonaws.com \
  --source-arn arn:aws:events:$REGION:"$ACCOUNT_ID":rule/$RULE_NAME \
  --region $REGION \
  2>/dev/null || echo "Permission already exists"

