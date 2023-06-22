install:
	go get github.com/aws/aws-lambda-go/lambda
	go get github.com/aws/aws-sdk-go


clean:
	rm -f main
	rm -f trigger.zip


package:
	GOOS=linux go build main.go
	zip trigger.zip main


build: clean package