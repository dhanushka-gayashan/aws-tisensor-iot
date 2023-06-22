from __future__ import print_function
import json
import boto3
import os
from botocore.exceptions import ClientError

region = os.environ['AWS_REGION']
sqs_ulr = os.environ['READ_SQS_URL']

sns = boto3.client('sns')
sqs = boto3.client('sqs', region_name=region)

def send_sms(data):
    mobile = data["mobile"]
    message = data["message"]
    content = f"**WARNING** - {message} ALERT"
    response = sns.publish(PhoneNumber=mobile, Message=content)
    return response['MessageId']


def delete_sqs_msg(sqs_url, receipt):
    sqs.delete_message(QueueUrl=sqs_url, ReceiptHandle=receipt)


def lambda_handler(event, context):
    record = event['Records'][0]
    print(record)
#     receipt = record["receiptHandle"]
#     body = json.loads(record["body"])
#     payload = json.loads(body['Message'])
#     try:
#         message_id = send_sms(payload)
#         delete_sqs_msg(sqs_ulr, receipt)
#     except ClientError as error:
#         print("Couldn't send message. Request Payload %s.", payload)
#         print(error)
#     else:
#         return message_id