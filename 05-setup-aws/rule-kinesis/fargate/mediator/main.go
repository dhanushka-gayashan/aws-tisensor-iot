package main

import (
	"encoding/json"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/kinesis"
	"github.com/gorilla/websocket"
	"log"
	"os"
	"time"
)

type MessageRequestPayload struct {
	Action  string `json:"action"`
	Payload struct {
		Message map[string]string `json:"message"`
	} `json:"payload"`
}

func (m *MessageRequestPayload) SetData(action string, pressure int64, temperature, humidity float64) {
	m.Action = action
	m.Payload.Message = make(map[string]string)
	m.Payload.Message["pressure"] = fmt.Sprintf("%d", pressure)
	m.Payload.Message["temperature"] = fmt.Sprintf("%.2f", temperature)
	m.Payload.Message["humidity"] = fmt.Sprintf("%.2f", humidity)
}

func readFromKinesisStream(ch chan MessageRequestPayload, region string, streamName string, shardId string) {
	log.Println("Streaming from Kinesis started....")

	accessKey := os.Getenv("AWS_ACCESS_KEY_ID")
	secretKey := os.Getenv("AWS_SECRET_ACCESS_KEY")

	var sess *session.Session
	var err error

	if accessKey != "" && secretKey != "" {
		sess, err = session.NewSession(&aws.Config{
			Region:      aws.String(region),
			Credentials: credentials.NewStaticCredentials(accessKey, secretKey, ""),
		})
	} else {
		sess, err = session.NewSession(&aws.Config{
			Region: aws.String(region),
		})
	}
	if err != nil {
		log.Println("Error creating session,", err)
		return
	}

	svc := kinesis.New(sess)
	shardIteratorArgs := &kinesis.GetShardIteratorInput{
		ShardId:           aws.String(shardId),
		ShardIteratorType: aws.String("LATEST"),
		StreamName:        aws.String(streamName),
	}

	shardIteratorRes, err := svc.GetShardIterator(shardIteratorArgs)
	if err != nil {
		fmt.Println("Error getting shard iterator,", err)
		return
	}

	getRecordsArgs := &kinesis.GetRecordsInput{
		ShardIterator: shardIteratorRes.ShardIterator,
		Limit:         aws.Int64(1),
	}

	for {
		getRecordsRes, err := svc.GetRecords(getRecordsArgs)
		if err != nil {
			log.Println("Error getting records,", err)
			continue // Retry fetching records instead of returning
		}

		for _, record := range getRecordsRes.Records {
			m := make(map[string]interface{})
			err := json.Unmarshal(record.Data, &m)
			if err != nil {
				log.Println(err)
				continue
			}

			message := &MessageRequestPayload{}
			message.SetData("BROADCAST", int64(m["pressure"].(float64)), m["temperature"].(float64), m["humidity"].(float64))
			ch <- *message
		}

		if getRecordsRes.NextShardIterator != nil {
			getRecordsArgs.ShardIterator = getRecordsRes.NextShardIterator
		}

		time.Sleep(time.Second)
	}
}

func writeToWebSocket(ch chan MessageRequestPayload, url string) {
	fmt.Println("Publishing to WebSocket started....")

	c, _, err := websocket.DefaultDialer.Dial(url, nil)
	if err != nil {
		fmt.Println("Error dialing WebSocket,", err)
		return
	}
	defer c.Close()

	writeTimeout := 10 * time.Second // Adjust the timeout duration as needed

	for {
		message := <-ch

		payloadJSON, err := json.Marshal(message)
		if err != nil {
			log.Printf("Failed to marshal payload: %v", err)
			continue // Retry sending the message instead of returning
		}

		payload := []byte(payloadJSON)
		err = c.WriteMessage(websocket.TextMessage, payload)
		if err != nil {
			fmt.Println("Error writing to WebSocket,", err)
			// Attempt to reconnect to WebSocket
			c, _, err = websocket.DefaultDialer.Dial(url, nil)
			if err != nil {
				fmt.Println("Error dialing WebSocket,", err)
			}
			continue // Retry sending the message instead of returning
		}

		// Reset write deadline
		c.SetWriteDeadline(time.Now().Add(writeTimeout))
	}
}

func main() {
	region := "us-east-1"
	streamName := "iot-topic-rule-kinesis-stream"
	shardId := "shardId-000000000000"
	wsApiUrl := "wss://ws.iot.dhanuzone.com/"

	ch := make(chan MessageRequestPayload)

	go readFromKinesisStream(ch, region, streamName, shardId)
	go writeToWebSocket(ch, wsApiUrl)

	select {}
}
