package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbiface"
	uuid2 "github.com/google/uuid"
	"log"
	"os"
)

type ReceiveData struct {
	Timestamp     string                 `json:"timestamp"`
	DeviceLabel   string                 `json:"device_label"`
	Location      string                 `json:"location"`
	Pressure      int64                  `json:"pressure"`
	Accelerometer map[string]interface{} `json:"accelerometer"`
	Gyroscope     map[string]interface{} `json:"gyroscope"`
	Magnetometer  map[string]interface{} `json:"magnetometer"`
	Temperature   float64                `json:"temperature"`
	Humidity      float64                `json:"humidity"`
}

type BaseData struct {
	Uuid      string `json:"uuid"`
	Timestamp string `json:"timestamp"`
}

type IntData struct {
	BaseData
	Data int64 `json:"data"`
}

type FloatData struct {
	BaseData
	Data float64 `json:"data"`
}

type MultiData struct {
	BaseData
	X float64 `json:"x"`
	Y float64 `json:"y"`
	Z float64 `json:"z"`
}

var dynaClient dynamodbiface.DynamoDBAPI

func main() {
	region := os.Getenv("AWS_REGION")
	awsSession, err := session.NewSession(&aws.Config{Region: aws.String(region)})
	if err != nil {
		return
	}
	dynaClient = dynamodb.New(awsSession)

	lambda.Start(handler)
}

func handler(ctx context.Context, e events.DynamoDBEvent) {
	for _, record := range e.Records {

		dbAttrMap := record.Change.NewImage

		converted := ConvertToDynamoDBAttribute(dbAttrMap)
		fmt.Printf("Converted: %+v\n", converted)

		var data ReceiveData
		err := dynamodbattribute.UnmarshalMap(converted, &data)
		if err != nil {
			log.Fatalf("Failed to unmarshal Record, %v", err)
		}

		err = SaveData(data)
		if err != nil {
			log.Fatalf("Failed to save Record, %v", err)
		}
	}
}

func ConvertToDynamoDBAttribute(values map[string]events.DynamoDBAttributeValue) map[string]*dynamodb.AttributeValue {
	converted := make(map[string]*dynamodb.AttributeValue)

	for k, v := range values {
		attributeValue := &dynamodb.AttributeValue{}
		switch v.DataType() {
		case events.DataTypeString:
			s := v.String()
			attributeValue.S = &s
		case events.DataTypeNumber:
			n := v.Number()
			attributeValue.N = &n
		case events.DataTypeBoolean:
			b := v.Boolean()
			attributeValue.BOOL = &b
		case events.DataTypeMap:
			m := v.Map()
			attributeValue.M = ConvertToDynamoDBAttribute(m)
		case events.DataTypeList:
			l := v.List()
			attributeValue.L = ConvertToDynamoDBAttributeList(l)
		}
		converted[k] = attributeValue
	}

	return converted
}

func ConvertToDynamoDBAttributeList(list []events.DynamoDBAttributeValue) []*dynamodb.AttributeValue {
	var converted []*dynamodb.AttributeValue

	for _, v := range list {
		attributeValue := &dynamodb.AttributeValue{}
		switch v.DataType() {
		case events.DataTypeString:
			s := v.String()
			attributeValue.S = &s
		case events.DataTypeNumber:
			n := v.Number()
			attributeValue.N = &n
		case events.DataTypeBoolean:
			b := v.Boolean()
			attributeValue.BOOL = &b
		case events.DataTypeMap:
			m := v.Map()
			attributeValue.M = ConvertToDynamoDBAttribute(m)
		case events.DataTypeList:
			l := v.List()
			attributeValue.L = ConvertToDynamoDBAttributeList(l)
		}
		converted = append(converted, attributeValue)
	}

	return converted
}

func SaveData(data ReceiveData) error {
	outputTables := map[string]string{
		"pressure":      "IOTOutputPressureTable",
		"accelerometer": "IOTOutputAccelerometerTable",
		"gyroscope":     "IOTOutputGyroscopeTable",
		"magnetometer":  "IOTOutputMagnetometerTable",
		"temperature":   "IOTOutputTemperatureTable",
		"humidity":      "IOTOutputHumidityTable",
	}

	fmt.Printf("%+v\n", data)
	fmt.Println("PRINT X AND Y AND Z")
	fmt.Println(data.Accelerometer)

	var input *dynamodb.PutItemInput
	if data.Pressure > 0 {
		item := new(IntData)
		item.Uuid = uuid2.New().String()
		item.Timestamp = data.Timestamp
		item.Data = data.Pressure

		av, err := dynamodbattribute.MarshalMap(item)
		if err != nil {
			return err
		}

		input = &dynamodb.PutItemInput{
			Item:      av,
			TableName: aws.String(outputTables["pressure"]),
		}
	} else if data.Temperature > 0.0 {
		item := new(FloatData)
		item.Uuid = uuid2.New().String()
		item.Timestamp = data.Timestamp
		item.Data = data.Temperature

		av, err := dynamodbattribute.MarshalMap(item)
		if err != nil {
			return err
		}

		input = &dynamodb.PutItemInput{
			Item:      av,
			TableName: aws.String(outputTables["temperature"]),
		}
	} else if data.Humidity > 0.0 {
		item := new(FloatData)
		item.Uuid = uuid2.New().String()
		item.Timestamp = data.Timestamp
		item.Data = data.Humidity

		av, err := dynamodbattribute.MarshalMap(item)
		if err != nil {
			return err
		}

		input = &dynamodb.PutItemInput{
			Item:      av,
			TableName: aws.String(outputTables["humidity"]),
		}
	} else if len(data.Accelerometer) > 0 {
		fmt.Println("I AM Accelerometer Accelerometer Accelerometer Accelerometer Accelerometer Accelerometer")

		item := new(MultiData)
		item.Uuid = uuid2.New().String()
		item.Timestamp = data.Timestamp
		item.X = data.Accelerometer["x"].(float64)
		item.Y = data.Accelerometer["y"].(float64)
		item.Z = data.Accelerometer["z"].(float64)

		av, err := dynamodbattribute.MarshalMap(item)
		if err != nil {
			return err
		}

		input = &dynamodb.PutItemInput{
			Item:      av,
			TableName: aws.String(outputTables["accelerometer"]),
		}
	} else if len(data.Gyroscope) > 0 {

		fmt.Println("I AM Gyroscope Gyroscope Gyroscope Gyroscope Gyroscope Gyroscope")

		item := new(MultiData)
		item.Uuid = uuid2.New().String()
		item.Timestamp = data.Timestamp
		item.X = data.Gyroscope["x"].(float64)
		item.Y = data.Gyroscope["y"].(float64)
		item.Z = data.Gyroscope["z"].(float64)

		av, err := dynamodbattribute.MarshalMap(item)
		if err != nil {
			return err
		}

		input = &dynamodb.PutItemInput{
			Item:      av,
			TableName: aws.String(outputTables["gyroscope"]),
		}
	} else if len(data.Magnetometer) > 0 {

		fmt.Println("I AM Magnetometer Magnetometer Magnetometer Magnetometer Magnetometer Magnetometer")

		item := new(MultiData)
		item.Uuid = uuid2.New().String()
		item.Timestamp = data.Timestamp
		item.X = data.Magnetometer["x"].(float64)
		item.Y = data.Magnetometer["y"].(float64)
		item.Z = data.Magnetometer["z"].(float64)

		av, err := dynamodbattribute.MarshalMap(item)
		if err != nil {
			return err
		}

		input = &dynamodb.PutItemInput{
			Item:      av,
			TableName: aws.String(outputTables["magnetometer"]),
		}
	}

	_, err := dynaClient.PutItem(input)
	if err != nil {
		return err
	}

	return nil
}
