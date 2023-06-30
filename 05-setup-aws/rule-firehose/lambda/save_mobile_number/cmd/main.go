package main

import (
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbiface"
	"os"
	"save_mobile_number/handlers"
)

var client dynamodbiface.DynamoDBAPI
var tableName string

func main() {
	region := os.Getenv("AWS_REGION")
	tableName = os.Getenv("TABLE")

	awsSession, err := session.NewSession(&aws.Config{Region: aws.String(region)})
	if err != nil {
		return
	}
	client = dynamodb.New(awsSession)

	lambda.Start(handler)
}

func handler(req events.APIGatewayProxyRequest) (*events.APIGatewayProxyResponse, error) {
	switch req.HTTPMethod {
	case "POST":
		return handlers.SaveMobileNumber(req, tableName, client)
	case "DELETE":
		return handlers.DeleteMobileNumber(req, tableName, client)
	case "OPTIONS":
		return handlers.OptionsMethod()
	default:
		return handlers.UnhandledMethod()
	}
}
