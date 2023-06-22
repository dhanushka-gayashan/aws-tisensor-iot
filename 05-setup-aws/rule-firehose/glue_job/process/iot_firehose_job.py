import sys
from awsglue.utils import getResolvedOptions

args = getResolvedOptions(sys.argv,['file','sqs_url'])

print ("File name is: ", args['file'])
print ("SQS URL is: ", args['sqs_url'])

# read parameters from SSM

# Load file from S3

# Read the file and find require data

# send message to SQS