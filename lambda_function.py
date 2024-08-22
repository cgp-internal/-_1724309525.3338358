import boto3
import json
import os
from typing import Dict, Any

lambda_function = lambda event, context: handler(event, context)

def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    try:
        headers = event.get('headers', {})
        auth_header = headers.get('Authorization')
        if not auth_header:
            return {
                'statusCode': 401,
                'body': json.dumps({'error': 'Unauthorized'})
            }
        
        kafka_topic = os.environ['KAFKA_TOPIC']
        kafka_message = json.dumps(event.get('body', {}))
        kafka_partitions = int(os.environ['KAFKA_PARTITIONS'])
        
        kafka_client = boto3.client('kafka')
        kafka_client.producer.send(kafka_topic, value=kafka_message.encode('utf-8'), partition=kafka_partitions)
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Authorized and sent to Kafka'})
        }
    
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }