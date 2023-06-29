package main

import (
	"encoding/json"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ecs"
	"log"
	"os"
)

func main() {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(os.Getenv("REGION")),
	})
	if err != nil {
		log.Fatalf("Failed to create a new AWS session: %v", err)
	}

	client := ecs.New(sess)
	resp, err := client.UpdateService(&ecs.UpdateServiceInput{
		Cluster:            aws.String(os.Getenv("CLUSTER")),
		Service:            aws.String(os.Getenv("SERVICE")),
		ForceNewDeployment: aws.Bool(true),
	})
	if err != nil {
		log.Fatalf("Failed to update ECS service: %v", err)
	}
	log.Println(resp)

	responseBody, _ := json.Marshal("ECS service updated successfully!")
	response := map[string]interface{}{
		"statusCode": 200,
		"body":       string(responseBody),
	}
	fmt.Println(response)
}
