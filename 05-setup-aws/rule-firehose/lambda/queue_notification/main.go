package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbiface"
	"github.com/aws/aws-sdk-go/service/sqs"
	uuid2 "github.com/google/uuid"
	"os"
)

type ReceiveData struct {
	Message string `json:"message"`
	Date    string `json:"date"`
}

type SendData struct {
	Message string `json:"message"`
	Mobile  string `json:"mobile"`
}

type MobileData struct {
	Mobile string `json:"mobile"`
	Uuid   string `json:"uuid"`
}

var region string
var readSqsUrl string
var writeSqsUrl string
var table string
var status string

var dynaClient dynamodbiface.DynamoDBAPI
var sqsClient *sqs.SQS

func main() {
	region = os.Getenv("AWS_REGION")
	readSqsUrl = os.Getenv("READ_SQS_URL")
	writeSqsUrl = os.Getenv("WRITE_SQS_URL")
	table = os.Getenv("TABLE")
	status = os.Getenv("STATUS")

	awsSession, err := session.NewSession(&aws.Config{Region: aws.String(region)})
	if err != nil {
		return
	}
	dynaClient = dynamodb.New(awsSession)
	sqsClient = sqs.New(awsSession)

	lambda.Start(handler)
}

func handler(ctx context.Context, event events.SQSEvent) {
	record := event.Records[0]
	var rd ReceiveData
	if err := json.Unmarshal([]byte(record.Body), &rd); err != nil {
		fmt.Printf("Error: Cannot Unmarshal Data")
	}

	if rd.Message == status {
		mobiles, err := getMobiles()
		if err != nil {
			fmt.Println("Error: Cannot fetch mobile list from dynamodb")
			return
		}

		message := fmt.Sprintf("***WARNING*** | STATUS: %s | UPDATE: %s", rd.Message, rd.Date)

		err = sendMessages(*mobiles, message)
		if err != nil {
			fmt.Println("Error: Cannot send messages to sqs")
			return
		}
	}

	_, err := sqsClient.DeleteMessage(&sqs.DeleteMessageInput{
		QueueUrl:      aws.String(readSqsUrl),
		ReceiptHandle: aws.String(record.ReceiptHandle),
	})
	if err != nil {
		fmt.Println("Error: Fail to delete message from notification sqs")
		return
	}
}

func getMobiles() (*[]MobileData, error) {
	input := &dynamodb.ScanInput{
		TableName: aws.String(table),
	}

	result, err := dynaClient.Scan(input)
	if err != nil {
		return nil, err
	}

	item := new([]MobileData)
	err = dynamodbattribute.UnmarshalListOfMaps(result.Items, item)

	return item, nil
}

func sendMessages(mobiles []MobileData, message string) error {
	for _, mobile := range mobiles {
		sd := new(SendData)
		sd.Mobile = mobile.Mobile
		sd.Message = message

		body, err := json.Marshal(sd)
		if err != nil {
			continue
		}

		uuid := uuid2.New().String()

		_, err = sqsClient.SendMessage(&sqs.SendMessageInput{
			MessageGroupId:         aws.String(uuid),
			MessageDeduplicationId: aws.String(uuid + "-deduplicateId"),
			MessageAttributes:      nil,
			MessageBody:            aws.String(string(body)),
			QueueUrl:               &writeSqsUrl,
		})
		if err != nil {
			fmt.Println("Error", err)
			continue
		}

		fmt.Println("Queued message for : ", mobile.Mobile)
	}

	return nil
}
