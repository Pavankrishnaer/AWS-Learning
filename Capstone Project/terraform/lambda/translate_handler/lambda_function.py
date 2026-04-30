import json
import boto3

# Initialize AWS Translate client
translate = boto3.client('translate')

def lambda_handler(event, context):
    """
    Translate text to multiple languages
    Expects JSON body with: text, target_language (optional)
    Supported languages: de (German), fr (French), es (Spanish), it (Italian)
    """
    try:
        # Parse request body
        if 'body' in event:
            body = json.loads(event['body'])
        else:
            body = event
        
        # Validate required field
        if 'text' not in body:
            return {
                'statusCode': 400,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'POST, OPTIONS'
                },
                'body': json.dumps({
                    'error': 'Missing required field: text'
                })
            }
        
        source_text = body['text']
        target_language = body.get('target_language', 'de')  # Default to German
        source_language = body.get('source_language', 'en')  # Default to English
        
        # Validate target language
        supported_languages = ['de', 'fr', 'es', 'it', 'en']
        if target_language not in supported_languages:
            return {
                'statusCode': 400,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'POST, OPTIONS'
                },
                'body': json.dumps({
                    'error': f'Unsupported language: {target_language}. Supported: {supported_languages}'
                })
            }
        
        # Skip translation if source and target are the same
        if source_language == target_language:
            return {
                'statusCode': 200,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'POST, OPTIONS'
                },
                'body': json.dumps({
                    'source_text': source_text,
                    'translated_text': source_text,
                    'source_language': source_language,
                    'target_language': target_language,
                    'message': 'No translation needed (same language)'
                })
            }
        
        # Call AWS Translate
        print(f"Translating from {source_language} to {target_language}: {source_text[:50]}...")
        
        response = translate.translate_text(
            Text=source_text,
            SourceLanguageCode=source_language,
            TargetLanguageCode=target_language
        )
        
        translated_text = response['TranslatedText']
        
        print(f"Translation successful: {translated_text[:50]}...")
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST, OPTIONS'
            },
            'body': json.dumps({
                'source_text': source_text,
                'translated_text': translated_text,
                'source_language': source_language,
                'target_language': target_language
            })
        }
        
    except Exception as e:
        print(f"Error translating text: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST, OPTIONS'
            },
            'body': json.dumps({
                'error': 'Translation failed',
                'details': str(e)
            })
        }