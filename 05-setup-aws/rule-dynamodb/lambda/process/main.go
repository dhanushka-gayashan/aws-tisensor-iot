package main

import (
	"context"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
	"github.com/aws/aws-sdk-go/aws"
	uuid2 "github.com/google/uuid"
	"log"
)

var client *dynamodb.Client

var output_tables = map[string]string{
	"pressure":      "IOTOutputPressureTable",
	"accelerometer": "IOTOutputAccelerometerTable",
	"gyroscope":     "IOTOutputGyroscopeTable",
	"magnetometer":  "IOTOutputMagnetometerTable",
	"humidity":      "IOTOutputHumidityTable",
}

func init() {
	cfg, _ := config.LoadDefaultConfig(context.Background())
	client = dynamodb.NewFromConfig(cfg)
}

func main() {
	lambda.Start(handler)
}

func handler(ctx context.Context, e events.DynamoDBEvent) {
	for _, r := range e.Records {
		values := r.Change.NewImage

		item := make(map[string]types.AttributeValue)
		item["uuid"] = &types.AttributeValueMemberS{Value: (uuid2.New()).String()}
		item["timestamp"] = &types.AttributeValueMemberS{Value: values["timestamp"].String()}
		item["data"] = &types.AttributeValueMemberS{Value: values["data"].String()}

		table := output_tables[values["type"].String()]

		_, err := client.PutItem(
			context.Background(),
			&dynamodb.PutItemInput{
				TableName: aws.String(table),
				Item:      item,
			},
		)
		if err != nil {
			log.Println(err)
		}
	}
}
