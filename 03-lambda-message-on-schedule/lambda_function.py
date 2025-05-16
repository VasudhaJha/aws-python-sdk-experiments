import json
from datetime import datetime, timezone

def lambda_handler(event, context):
    now = datetime.now(timezone.utc).isoformat()
    weekday = datetime.now(timezone.utc).strftime('%A')

    log_event = {
        "timestamp": now,
        "function": context.function_name,
        "trigger": event.get("source", "manual"),
        "weekday": weekday,
        "message": None
    }

    if weekday == "Monday":
        log_event["message"] = "It's Friday — weekend fun begins!"

    # Print structured log
    print(json.dumps(log_event))

    return log_event
