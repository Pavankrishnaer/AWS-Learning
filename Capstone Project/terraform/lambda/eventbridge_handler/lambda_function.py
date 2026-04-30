import json
import boto3
from datetime import datetime

# Initialize AWS clients
dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')
ssm = boto3.client('ssm')

def get_ssm_parameter(param_name):
    """Retrieve parameter from SSM Parameter Store"""
    try:
        response = ssm.get_parameter(Name=param_name)
        return response['Parameter']['Value']
    except Exception as e:
        print(f"Error retrieving SSM parameter {param_name}: {str(e)}")
        return None

def lambda_handler(event, context):
    """
    Handle EventBridge scheduled events
    Event types: daily_sales_report, weekly_newsletter, cleanup_old_orders
    """
    try:
        print(f"EventBridge event received: {json.dumps(event)}")
        
        event_type = event.get('event_type', 'unknown')
        message = event.get('message', 'No message provided')
        
        print(f"Event Type: {event_type}")
        print(f"Message: {message}")
        
        if event_type == "daily_sales_report":
            return handle_daily_sales_report(event)
        elif event_type == "weekly_newsletter":
            return handle_weekly_newsletter(event)
        elif event_type == "cleanup_old_orders":
            return handle_cleanup_old_orders(event)
        else:
            print(f"Unknown event type: {event_type}")
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': f'Processed unknown event: {event_type}'
                })
            }
        
    except Exception as e:
        print(f"Error processing EventBridge event: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Internal server error'
            })
        }

def handle_daily_sales_report(event):
    """Generate and send daily sales report"""
    print("Generating daily sales report...")
    
    # Get orders table name from SSM
    table_name = get_ssm_parameter('/ellore/capstone/dynamodb/orders-table-name')
    
    if table_name:
        table = dynamodb.Table(table_name)
        
        # Query today's orders (simplified - production would use date filtering)
        try:
            response = table.scan(Limit=100)
            order_count = len(response.get('Items', []))
            print(f"Found {order_count} recent orders")
        except Exception as e:
            print(f"Error querying orders: {str(e)}")
            order_count = 0
    else:
        order_count = 0
    
    # Send report via SNS
    sns_topic_arn = get_ssm_parameter('/ellore/capstone/sns/order-notifications-topic-arn')
    
    if sns_topic_arn:
        try:
            report_message = f"""
ELLORE Daily Sales Report
Date: {datetime.utcnow().strftime('%Y-%m-%d')}

Total Orders: {order_count}
Status: Report generated successfully

This is an automated report from ELLORE EventBridge.
            """
            
            sns.publish(
                TopicArn=sns_topic_arn,
                Subject='ELLORE Daily Sales Report',
                Message=report_message
            )
            print("Daily sales report sent via SNS")
        except Exception as e:
            print(f"Error sending SNS report: {str(e)}")
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Daily sales report generated',
            'order_count': order_count
        })
    }

def handle_weekly_newsletter(event):
    """Send weekly newsletter to subscribers"""
    print("Processing weekly newsletter...")
    
    # Get newsletter subscribers from DynamoDB
    table_name = get_ssm_parameter('/ellore/capstone/dynamodb/newsletter-table-name')
    
    if table_name:
        table = dynamodb.Table(table_name)
        
        try:
            response = table.scan()
            subscribers = response.get('Items', [])
            subscriber_count = len(subscribers)
            print(f"Found {subscriber_count} newsletter subscribers")
        except Exception as e:
            print(f"Error querying subscribers: {str(e)}")
            subscriber_count = 0
    else:
        subscriber_count = 0
    
    # Publish notification via SNS
    sns_topic_arn = get_ssm_parameter('/ellore/capstone/sns/order-notifications-topic-arn')
    
    if sns_topic_arn:
        try:
            newsletter_message = f"""
ELLORE Weekly Newsletter Trigger
Date: {datetime.utcnow().strftime('%Y-%m-%d')}

Subscriber Count: {subscriber_count}
Status: Newsletter campaign initiated

This is an automated trigger from ELLORE EventBridge.
            """
            
            sns.publish(
                TopicArn=sns_topic_arn,
                Subject='ELLORE Weekly Newsletter Campaign',
                Message=newsletter_message
            )
            print("Newsletter notification sent via SNS")
        except Exception as e:
            print(f"Error sending SNS notification: {str(e)}")
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Weekly newsletter triggered',
            'subscriber_count': subscriber_count
        })
    }

def handle_cleanup_old_orders(event):
    """Cleanup expired orders (TTL handles this automatically, this is a monitoring job)"""
    print("Running cleanup check for old orders...")
    
    # In production, this would check for orders that need manual cleanup
    # For now, it's a placeholder that logs the cleanup event
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Cleanup check completed (TTL handles automatic deletion)'
        })
    }