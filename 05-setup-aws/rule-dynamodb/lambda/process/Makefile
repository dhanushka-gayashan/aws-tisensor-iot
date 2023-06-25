install:
	go get github.com/aws/aws-lambda-go/lambda
	go get github.com/aws/aws-sdk-go
	go get github.com/aws/aws-lambda-go/events
	go get github.com/google/uuid


clean:
	rm -f main
	rm -f process.zip


package:
	GOOS=linux go build main.go
	zip process.zip main


build: clean package

