import sys
import boto3
import uuid
import json
import datetime
from awsglue.utils import getResolvedOptions


args = getResolvedOptions(sys.argv,['region','bucket','file','sqs_url'])

region = args['region']
bucket = args['bucket']
file = args['file']
sqs_url = args['sqs_url']

send_message = False

# TODO: read parameters from SSM

# TODO: Load file from S3

# TODO: read the file and find require data
# TODO: Remove
send_message = True

# send notification origin message
if send_message:
    # generate message id
    message_id = str(uuid.uuid4())

    # construct data
    data = {
        "message": "HIGH PRESSURE",
        "date": datetime.datetime.now().strftime("%I:%M%p on %B %d, %Y")
    }

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
        MessageBody=json.dumps(data)
    )

    # print received MessageId
    print(response['MessageId'])

# final message
print("Glue Job executed successfully. You can get more details from AWS console.")