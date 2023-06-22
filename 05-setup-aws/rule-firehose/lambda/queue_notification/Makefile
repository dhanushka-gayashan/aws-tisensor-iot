install:
	go get github.com/aws/aws-lambda-go/lambda
	go get github.com/aws/aws-sdk-go-v2
	go get github.com/aws/aws-sdk-go-v2/config
	go get github.com/aws/aws-sdk-go-v2/service/dynamodb
	go get github.com/aws/aws-sdk-go-v2/service/sqs
	go get github.com/google/uuid


clean:
	rm -f main
	rm -f notification.zip


package:
	GOOS=linux go build main.go
	zip notification.zip main


build: clean package