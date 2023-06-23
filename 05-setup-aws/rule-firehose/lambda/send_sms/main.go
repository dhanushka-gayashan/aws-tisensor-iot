package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sns"
	"github.com/aws/aws-sdk-go/service/sqs"
	"os"
)

type ReceiveData struct {
	Message string `json:"message"`
	Mobile  string `json:"mobile"`
}

var region string
var readSqsUrl string

var snsClient *sns.SNS
var sqsClient *sqs.SQS

func main() {
	region = os.Getenv("AWS_REGION")
	readSqsUrl = os.Getenv("READ_SQS_URL")

	awsSession, err := session.NewSession(&aws.Config{Region: aws.String(region)})
	if err != nil {
		return
	}
	snsClient = sns.New(awsSession)
	sqsClient = sqs.New(awsSession)

	lambda.Start(handler)
}

func handler(ctx context.Context, event events.SQSEvent) {
	record := event.Records[0]
	var rd ReceiveData
	if err := json.Unmarshal([]byte(record.Body), &rd); err != nil {
		fmt.Printf("Error: Cannot Unmarshal Data")
	}

	//sess := session.Must(session.NewSessionWithOptions(session.Options{
	//	SharedConfigState: session.SharedConfigEnable,
	//}))
	//
	//svc := sns.New(sess)

	result, err := snsClient.Publish(&sns.PublishInput{
		Message:     aws.String(rd.Message),
		PhoneNumber: aws.String(rd.Mobile),
	})
	if err != nil {
		fmt.Println(err.Error())
		return
	}
	fmt.Println("Successfully processed", *result.MessageId)

	_, err = sqsClient.DeleteMessage(&sqs.DeleteMessageInput{
		QueueUrl:      aws.String(readSqsUrl),
		ReceiptHandle: aws.String(record.ReceiptHandle),
	})
	if err != nil {
		fmt.Println("Error: Fail to delete message from send sms sqs")
		return
	}
}
