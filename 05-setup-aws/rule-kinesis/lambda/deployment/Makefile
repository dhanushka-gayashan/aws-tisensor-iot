install:
	go get github.com/aws/aws-sdk-go


clean:
	rm -f main
	rm -f deployment.zip


package:
	GOOS=linux go build main.go
	zip deployment.zip main


build: clean package