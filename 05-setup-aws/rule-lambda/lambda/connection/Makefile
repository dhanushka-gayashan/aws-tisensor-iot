install:
	go get github.com/aws/aws-lambda-go
	go get github.com/aws/aws-sdk-go-v2
	go get github.com/aws/aws-sdk-go-v2/config
	go get github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue
	go get github.com/aws/aws-sdk-go-v2/feature/dynamodb/expression
	go get github.com/aws/aws-sdk-go-v2/service/apigatewaymanagementapi
	go get github.com/aws/aws-sdk-go-v2/service/dynamodb


clean:
	rm -f main
	rm -f connection.zip


package:
	GOOS=linux go build main.go
	zip connection.zip main


build: clean package