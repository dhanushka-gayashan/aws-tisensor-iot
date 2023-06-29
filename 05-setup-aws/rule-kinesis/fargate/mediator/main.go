package main

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/kinesis"
	"time"
)

func readFromKinesisStream(ch chan string, region string, streamName string, shardId string) {

	fmt.Println("Streaming from Kinesis started....")

	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region)},
	)

	if err != nil {
		fmt.Println("Error creating session,", err)
		return
	}

	svc := kinesis.New(sess)

	shardIteratorArgs := &kinesis.GetShardIteratorInput{
		ShardId:           aws.String(shardId),
		ShardIteratorType: aws.String("TRIM_HORIZON"),
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
			fmt.Println("Error getting records,", err)
			return
		}

		for _, record := range getRecordsRes.Records {
			ch <- string(record.Data)
		}

		if getRecordsRes.NextShardIterator != nil {
			getRecordsArgs.ShardIterator = getRecordsRes.NextShardIterator
		}

		time.Sleep(time.Second)
	}
}

//func writeToWebSocket(ch chan string, url string) {
//	c, _, err := websocket.DefaultDialer.Dial(url, nil)
//	if err != nil {
//		fmt.Println("Error dialing WebSocket,", err)
//		return
//	}
//	defer c.Close()
//
//	for {
//		message := <-ch
//		err := c.WriteMessage(websocket.TextMessage, []byte(message))
//		if err != nil {
//			fmt.Println("Error writing to WebSocket,", err)
//			return
//		}
//	}
//}

func main() {

	region := "us-east-1"
	streamName := "iot-topic-rule-kinesis-stream"
	shardId := "shardId-000000000000"

	//wsApiUrl := ""

	ch := make(chan string)

	go readFromKinesisStream(ch, region, streamName, shardId)
	//go writeToWebSocket(ch, "ws://my.websocket.url")

	for data := range ch {
		fmt.Println(data)
	}

	select {}
}
