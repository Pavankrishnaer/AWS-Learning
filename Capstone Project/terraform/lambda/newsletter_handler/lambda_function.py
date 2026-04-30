import json
import boto3
from datetime import datetime

# Initialize AWS clients
dynamodb = boto3.resource("dynamodb")
ssm = boto3.client("ssm")


def get_ssm_parameter(param_name):
    """Retrieve parameter from SSM Parameter Store"""
    try:
        response = ssm.get_parameter(Name=param_name)
        return response["Parameter"]["Value"]
    except Exception as e:
        print(f"Error retrieving SSM parameter {param_name}: {str(e)}")
        raise


def lambda_handler(event, context):
    """
    Handle newsletter subscriptions
    Expects JSON body with: email, name (optional)
    """
    try:
        # Parse request body
        if "body" in event:
            body = json.loads(event["body"])
        else:
            body = event

        # Validate required fields
        if "email" not in body:
            return {
                "statusCode": 400,
                "headers": {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "Content-Type",
                    "Access-Control-Allow-Methods": "POST, OPTIONS",
                },
                "body": json.dumps({"error": "Missing required field: email"}),
            }

        # Get DynamoDB table name from SSM
        table_name = get_ssm_parameter(
            "/ellore/capstone/dynamodb/newsletter-table-name"
        )
        table = dynamodb.Table(table_name)

        # Check if email already exists
        email = body["email"].lower()

        try:
            response = table.get_item(Key={"email": email})
            if "Item" in response:
                return {
                    "statusCode": 200,
                    "headers": {
                        "Access-Control-Allow-Origin": "*",
                        "Access-Control-Allow-Headers": "Content-Type",
                        "Access-Control-Allow-Methods": "POST, OPTIONS",
                    },
                    "body": json.dumps({"message": "Email already subscribed"}),
                }
        except Exception as e:
            print(f"Error checking existing subscription: {str(e)}")

        # Create subscription
        subscribed_at = datetime.utcnow().isoformat()

        item = {"email": email, "subscribedAt": subscribed_at, "status": "active"}

        # Add optional name if provided
        if "name" in body:
            item["name"] = body["name"]

        table.put_item(Item=item)

        print(f"Newsletter subscription: {email}")

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "POST, OPTIONS",
            },
            "body": json.dumps({"message": "Successfully subscribed to newsletter"}),
        }

    except Exception as e:
        print(f"Error processing newsletter subscription: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "POST, OPTIONS",
            },
            "body": json.dumps({"error": "Internal server error"}),
        }
