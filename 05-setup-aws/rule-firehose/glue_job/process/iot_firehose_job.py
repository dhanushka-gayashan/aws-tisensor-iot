import sys
import boto3
import uuid
from awsglue.utils import getResolvedOptions


args = getResolvedOptions(sys.argv,['region','bucket','file','sqs_url'])

region = args['region']
bucket = args['bucket']
file = args['file']
sqs_url = args['sqs_url']

# read parameters from SSM

# Load file from S3

# Read the file and find require data

# generate message id
message_id = str(uuid.uuid4())

# send message to SQS
sqs = boto3.client('sqs', region_name=region)
queue_url = sqs_url
response = sqs.send_message(
    QueueUrl=queue_url,
    DelaySeconds=0,
    MessageAttributes={
        'Origin': {
            'DataType': 'String',
            'StringValue': 'Glue Job'
        },
        'Source': {
            'DataType': 'String',
            'StringValue': 'S3'
        }
    },
    MessageGroupId=message_id,
    MessageDeduplicationId=message_id+"-duplicate-id",
    MessageBody=('Example message'))

# print output the received MessageId
print(response['MessageId'])