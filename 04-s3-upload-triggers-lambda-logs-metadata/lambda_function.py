import json
import boto3

s3 = boto3.client("s3")

def lambda_handler(event, context):
    records = event["Records"]

    for record in records:
        bucket_name = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]
        size = record["s3"]["object"]["size"]
        event_time = record["eventTime"]

        response = s3.head_object(Bucket=bucket_name, Key=key)

        log_entry = {
            "bucket": bucket_name,
            "key": key,
            "size_bytes": size,
            "event_time": event_time,
            "content_type": response.get("ContentType"),
            "last_modified": response.get("LastModified").isoformat(),
            "user_metadata": response.get("Metadata", {})
        }

        print(json.dumps(log_entry))

