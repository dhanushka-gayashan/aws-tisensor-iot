import sys
import boto3
import datetime
import pandas as pd
import json
import re
import uuid
from awsglue.utils import getResolvedOptions


args = getResolvedOptions(sys.argv,['region','bucket','file','sqs_url', 'pressure_param', 'temperature_param'])
region = args['region']
s3_bucket = args['bucket']
s3_file_key = args['file']
sqs_url = args['sqs_url']
pressure_param = args['pressure_param']
temperature_param = args['temperature_param']


sqs = boto3.client('sqs', region_name=region)
ssm = boto3.client('ssm')
s3 = boto3.client('s3')


def get_parameter(name):
    parameter = ssm.get_parameter(Name=name, WithDecryption=True)
    return parameter['Parameter']['Value']


def get_df():
    obj = s3.get_object(Bucket=s3_bucket, Key=s3_file_key)
    data = obj['Body'].read().decode('utf-8')
    data = re.sub('}{', '}\n{', data)
    lines = data.splitlines()
    df = pd.concat([pd.json_normalize(json.loads(line)) for line in lines])
    return df


def process(df, pressure_max, temperature_max):
    return [len(df[df['pressure'] > pressure_max]) > 0, len(df[df['temperature'] > temperature_max]) > 0]


def send_message(message):
    # generate message id
    message_id = str(uuid.uuid4())

    # send message to SQS
    response = sqs.send_message(
        QueueUrl=sqs_url,
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
        MessageBody=json.dumps({
            "message": message,
            "date": datetime.datetime.now().strftime("%I:%M%p on %B %d, %Y")
        })
    )

    # print received MessageId
    print(message, response['MessageId'])


def execute():
    # read parameter from ssm
    pressure_max_level = int(get_parameter(pressure_param))
    temperature_max_level = int(get_parameter(temperature_param))

    # get pandas df
    df = get_df()

    # process df
    results = process(df, pressure_max_level, temperature_max_level)

    # send messages
    if results[0]:
        send_message("HIGH PRESSURE")

    if results[1]:
        send_message("HIGH TEMPERATURE")

    # final message
    print("Glue Job executed successfully. You can get more details from AWS console.")


# start the job
execute()