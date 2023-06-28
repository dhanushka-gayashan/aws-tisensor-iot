package handler

import (
	"connection/helper"
	"connection/model"
	"context"
	"encoding/json"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"log"
	"net/http"
	"os"
	"time"
)

func Chat(ctx context.Context, event events.APIGatewayWebsocketProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Print("receive chat message")

	const chatAction = "CHAT"

	svc, err := helper.NewDynamoDB(ctx)
	if err != nil {
		return events.APIGatewayProxyResponse{}, err
	}

	item, err := attributevalue.MarshalMap(model.Connection{
		ConnectionID:   event.RequestContext.ConnectionID,
		ExpirationTime: int(time.Now().Add(5 * time.Minute).Unix()),
	})
	if err != nil {
		return events.APIGatewayProxyResponse{}, err
	}

	input := &dynamodb.PutItemInput{
		TableName: aws.String(os.Getenv("DYNAMODB_TABLE")),
		Item:      item,
	}

	if _, err = svc.PutItem(ctx, input); err != nil {
		return events.APIGatewayProxyResponse{}, err
	}

	response := model.Response[model.PongResponsePayload]{
		Action:   chatAction,
		Response: model.PongResponsePayload{},
	}

	content, err := json.Marshal(response)
	if err != nil {
		return events.APIGatewayProxyResponse{}, err
	}

	log.Printf("chat response: %s", string(content))

	return events.APIGatewayProxyResponse{
		Body:       string(content),
		StatusCode: http.StatusOK,
	}, nil
}
