package main

import (
	"connection/handler"
	"context"
	"encoding/json"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"log"
)

func Handler(ctx context.Context, event events.APIGatewayWebsocketProxyRequest) (events.APIGatewayProxyResponse, error) {
	content, err := json.Marshal(event)
	if err != nil {
		return events.APIGatewayProxyResponse{}, err
	}

	log.Printf("new event. content: %s", string(content))

	switch event.RequestContext.RouteKey {
	case "$connect":
		return handler.Connect(ctx, event)
	case "$disconnect":
		return handler.Disconnect(ctx, event)
	case "CHAT":
		return handler.Chat(ctx, event)
	case "BROADCAST":
		return handler.Broadcast(ctx, event)
	default:
		return events.APIGatewayProxyResponse{Body: "no handler", StatusCode: 200}, nil
	}
}

func main() {
	lambda.Start(Handler)
}
