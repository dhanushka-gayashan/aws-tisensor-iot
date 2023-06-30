package mobile

import (
	"encoding/json"
	"errors"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbiface"
)

type MNumber struct {
	Mobile string `json:"mobile"`
	Uuid   string `json:"uuid"`
}

func SaveMobileNumber(req events.APIGatewayProxyRequest, tableName string, client dynamodbiface.DynamoDBAPI) (*MNumber, error) {
	var mn MNumber

	if err := json.Unmarshal([]byte(req.Body), &mn); err != nil {
		return nil, errors.New("invalid mobile number data")
	}

	av, err := dynamodbattribute.MarshalMap(mn)
	if err != nil {
		return nil, errors.New("could not marshal item")
	}

	input := &dynamodb.PutItemInput{
		Item:      av,
		TableName: aws.String(tableName),
	}

	_, err = client.PutItem(input)
	if err != nil {
		return nil, errors.New("could not dynamo put item")
	}

	return &mn, nil
}

func DeleteMobileNumber(mNumber string, tableName string, dynaClient dynamodbiface.DynamoDBAPI) error {
	input := &dynamodb.DeleteItemInput{
		Key: map[string]*dynamodb.AttributeValue{
			"mobile": {
				S: aws.String(mNumber),
			},
		},
		TableName: aws.String(tableName),
	}

	_, err := dynaClient.DeleteItem(input)
	if err != nil {
		return errors.New("could not delete item")
	}

	return nil
}
