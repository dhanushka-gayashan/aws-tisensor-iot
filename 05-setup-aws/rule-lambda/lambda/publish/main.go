package main

import (
	"context"
	"encoding/json"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/apigatewaymanagementapi"
	"log"
	"os"
)

type Event struct {
	Pressure    int64   `json:"pressure"`
	Temperature float64 `json:"temperature"`
	Humidity    float64 `json:"humidity"`
}

type Payload struct {
	Message Event `json:"message"`
}

type Message struct {
	Action  string  `json:"action"`
	Payload Payload `json:"payload"`
}

func Handler(ctx context.Context, event Event) error {
	// Create the payload
	message := Message{
		Action: "BROADCAST",
		Payload: Payload{
			Message: event,
		},
	}

	// Convert the payload to JSON
	payloadJSON, err := json.Marshal(message)
	if err != nil {
		log.Printf("Failed to marshal payload: %v", err)
		return err
	}

	// Create a session using the Lambda function's IAM role credentials
	sess, err := session.NewSession()
	if err != nil {
		log.Printf("Failed to create AWS session: %v", err)
		return err
	}

	// Create a new API Gateway Management API client
	apiClient := apigatewaymanagementapi.New(sess, aws.NewConfig().WithEndpoint(os.Getenv("API_GATEWAY_ENDPOINT")))

	// Prepare the payload to send
	payload := []byte(payloadJSON)

	// Send the payload to the WebSocket connection(s)
	_, err = apiClient.PostToConnection(&apigatewaymanagementapi.PostToConnectionInput{
		//ConnectionId: aws.String(event.DeviceLabel),
		ConnectionId: aws.String("HOm7Hc0roAMCIGQ="),
		Data:         payload,
	})
	if err != nil {
		log.Printf("Failed to send message to WebSocket connection: %v", err)
		return err
	}

	return nil
}

func main() {
	lambda.Start(Handler)
}
