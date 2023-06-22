package main

import (
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/glue"
	"os"
)

var jobName string
var sqsUrl string

var glueClient *glue.Glue

func handler(even events.S3Event) (*glue.StartJobRunOutput, error) {
	record := even.Records[0]
	response, err := glueClient.StartJobRun(&glue.StartJobRunInput{
		JobName: aws.String(jobName),
		Arguments: map[string]*string{
			"--file":    aws.String(record.S3.Object.Key),
			"--sqs_url": aws.String(sqsUrl),
		},
	})
	if err != nil {
		return nil, err
	}

	return response, nil
}

func main() {
	region := os.Getenv("AWS_REGION")
	jobName = os.Getenv("JOB_NAME")
	sqsUrl = os.Getenv("SQS_URL")

	awsSession, err := session.NewSession(&aws.Config{Region: aws.String(region)})
	if err != nil {
		return
	}
	glueClient = glue.New(awsSession)

	lambda.Start(handler)
}
