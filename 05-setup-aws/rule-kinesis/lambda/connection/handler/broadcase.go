package handler

import (
	"connection/helper"
	"connection/model"
	"context"
	"encoding/json"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/expression"
	"github.com/aws/aws-sdk-go-v2/service/apigatewaymanagementapi"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"log"
	"net/http"
	"os"
)

func Broadcast(ctx context.Context, event events.APIGatewayWebsocketProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Print("receive broadcast message")

	const broadcastAction = "BROADCAST"

	svc, err := helper.NewDynamoDB(ctx)
	if err != nil {
		return events.APIGatewayProxyResponse{}, err
	}

	var request model.Request[model.MessageRequestPayload]
	if err := json.Unmarshal([]byte(event.Body), &request); err != nil {
		return events.APIGatewayProxyResponse{}, err
	}

	filter := expression.Name("ConnectionID").NotEqual(expression.Value(event.RequestContext.ConnectionID))
	projection := expression.NamesList(expression.Name("ConnectionID"))
	expr, err := expression.NewBuilder().WithFilter(filter).WithProjection(projection).Build()
	if err != nil {
		return events.APIGatewayProxyResponse{}, err
	}

	input := &dynamodb.ScanInput{
		TableName:                 aws.String(os.Getenv("DYNAMODB_TABLE")),
		ExpressionAttributeNames:  expr.Names(),
		ExpressionAttributeValues: expr.Values(),
		FilterExpression:          expr.Filter(),
		ProjectionExpression:      expr.Projection(),
		Limit:                     aws.Int32(100),
	}

	output, err := svc.Scan(ctx, input)
	if err != nil {
		return events.APIGatewayProxyResponse{}, err
	}

	log.Printf("found %d active connections", output.Count)

	api, err := helper.NewAPIGatewayManagementAPI(ctx)
	if err != nil {
		return events.APIGatewayProxyResponse{}, err
	}

	for _, item := range output.Items {
		var conn model.Connection
		if err := attributevalue.UnmarshalMap(item, &conn); err != nil {
			return events.APIGatewayProxyResponse{}, err
		}

		newMessage := model.Response[model.MessageRequestPayload]{
			Action: broadcastAction,
			Response: model.MessageRequestPayload{
				Message: request.Payload.Message,
			},
		}
		data, err := json.Marshal(newMessage)
		if err != nil {
			return events.APIGatewayProxyResponse{}, err
		}

		input := &apigatewaymanagementapi.PostToConnectionInput{
			ConnectionId: aws.String(conn.ConnectionID),
			Data:         data,
		}

		if _, err = api.PostToConnection(ctx, input); err != nil {
			return events.APIGatewayProxyResponse{}, err
		}
	}

	return events.APIGatewayProxyResponse{
		StatusCode: http.StatusOK,
	}, nil
}
