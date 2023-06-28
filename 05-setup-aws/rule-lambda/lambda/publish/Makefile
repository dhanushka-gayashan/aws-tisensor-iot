install:
	go get github.com/aws/aws-lambda-go/events
	go get github.com/aws/aws-sdk-go/aws
	go get github.com/aws/aws-sdk-go/aws/session
	go get github.com/aws/aws-sdk-go/service/apigatewaymanagementapi


clean:
	rm -f main
	rm -f publish.zip


package:
	GOOS=linux go build main.go
	zip publish.zip main


build: clean package