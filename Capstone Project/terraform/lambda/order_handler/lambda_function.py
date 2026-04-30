import json
import boto3
from datetime import datetime, timedelta
from uuid import uuid4

# Initialize AWS clients
dynamodb = boto3.resource("dynamodb")
ssm = boto3.client("ssm")
sns = boto3.client("sns")  # ← ADDED


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
    Handle order submissions
    Expects JSON body with: customerId, customerEmail, items, totalAmount
    """
    try:
        # Parse request body
        if "body" in event:
            body = json.loads(event["body"])
        else:
            body = event

        # Validate required fields
        required_fields = ["customerId", "customerEmail", "items", "totalAmount"]
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
        table_name = get_ssm_parameter("/ellore/capstone/dynamodb/orders-table-name")
        table = dynamodb.Table(table_name)

        # Generate order ID and timestamps
        order_id = str(uuid4())
        order_date = datetime.utcnow().isoformat()
        expires_at = int((datetime.utcnow() + timedelta(days=365)).timestamp())

        # Store order in DynamoDB
        item = {
            "orderId": order_id,
            "customerId": body["customerId"],
            "customerEmail": body["customerEmail"],
            "items": body["items"],
            "totalAmount": body["totalAmount"],
            "orderDate": order_date,
            "expiresAt": expires_at,
            "status": "pending",
        }

        # Add optional fields if present
        if "shippingAddress" in body:
            item["shippingAddress"] = body["shippingAddress"]
        if "billingAddress" in body:
            item["billingAddress"] = body["billingAddress"]
        if "customerName" in body:
            item["customerName"] = body["customerName"]
        if "phone" in body:
            item["phone"] = body["phone"]

        table.put_item(Item=item)

        print(f"Order created: {order_id}")

        # ═══════════════════════════════════════════
        # ✅ SEND SNS ALERT (NEW CODE)
        # ═══════════════════════════════════════════
        try:
            # Get SNS topic ARN from SSM (or use environment variable)
            sns_topic_arn = get_ssm_parameter("/ellore/capstone/sns/order-alerts-topic-arn")
            
            # Build notification message
            customer_name = body.get("customerName", "N/A")
            total_amount = body["totalAmount"]
            items_count = len(body["items"])
            
            message = f"""
🛍️ NEW ORDER RECEIVED

Order ID: {order_id}
Customer: {customer_name}
Email: {body["customerEmail"]}
Total Amount: €{total_amount:.2f}
Items: {items_count}
Order Date: {order_date}

Order Details:
{json.dumps(body["items"], indent=2)}

Status: Pending
            """
            
            # Publish to SNS
            sns_response = sns.publish(
                TopicArn=sns_topic_arn,
                Subject=f"🛍️ ELLORE - New Order #{order_id[:8]}",
                Message=message
            )
            
            print(f"SNS notification sent: {sns_response['MessageId']}")
            
        except Exception as sns_error:
            # Don't fail the order if SNS fails - just log it
            print(f"Warning: Failed to send SNS notification: {str(sns_error)}")
        # ═══════════════════════════════════════════

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "POST, OPTIONS",
            },
            "body": json.dumps(
                {
                    "message": "Order created successfully",
                    "orderId": order_id,
                    "orderDate": order_date,
                }
            ),
        }

    except Exception as e:
        print(f"Error processing order: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "POST, OPTIONS",
            },
            "body": json.dumps({"error": "Internal server error"}),
        }