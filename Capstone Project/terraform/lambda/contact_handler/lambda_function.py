import json
import boto3
import os
from datetime import datetime, timedelta
from uuid import uuid4

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
    Handle contact form submissions
    Expects JSON body with: name, email, subject, message
    """
    try:
        # Parse request body
        if "body" in event:
            body = json.loads(event["body"])
        else:
            body = event

        # Validate required fields
        required_fields = ["name", "email", "subject", "message"]
        for field in required_fields:
            if field not in body:
                return {
                    "statusCode": 400,
                    "headers": {
                        "Access-Control-Allow-Origin": "*",
                        "Access-Control-Allow-Headers": "Content-Type",
                        "Access-Control-Allow-Methods": "POST, OPTIONS",
                    },
                    "body": json.dumps({"error": f"Missing required field: {field}"}),
                }

        # Get DynamoDB table name from SSM
        table_name = get_ssm_parameter("/ellore/capstone/dynamodb/contacts-table-name")
        table = dynamodb.Table(table_name)

        # Generate contact ID and timestamps
        contact_id = str(uuid4())
        submitted_at = datetime.utcnow().isoformat()
        expires_at = int((datetime.utcnow() + timedelta(days=90)).timestamp())

        # Store contact in DynamoDB
        item = {
            "contactId": contact_id,
            "name": body["name"],
            "email": body["email"],
            "subject": body["subject"],
            "message": body["message"],
            "submittedAt": submitted_at,
            "expiresAt": expires_at,
            "status": "new",
        }

        table.put_item(Item=item)

        print(f"Contact form submitted: {contact_id}")

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "POST, OPTIONS",
            },
            "body": json.dumps(
                {
                    "message": "Contact form submitted successfully",
                    "contactId": contact_id,
                }
            ),
        }

    except Exception as e:
        print(f"Error processing contact form: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "POST, OPTIONS",
            },
            "body": json.dumps({"error": "Internal server error"}),
        }
