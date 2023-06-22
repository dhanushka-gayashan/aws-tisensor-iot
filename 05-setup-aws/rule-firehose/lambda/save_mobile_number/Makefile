install:
	go get github.com/aws/aws-lambda-go/lambda
	go get github.com/aws/aws-sdk-go
	go get github.com/google/uuid


clean:
	rm -f main
	rm -f mobile.zip


package:
	GOOS=linux go build ./cmd/main.go
	zip mobile.zip main


build: clean package