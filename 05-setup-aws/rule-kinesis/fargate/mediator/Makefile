install:
	go get github.com/gorilla/websocket
	go get github.com/aws/aws-sdk-go


# TODO
run:
	rm -f main
	rm -f trigger.zip

# TODO
package:
	GOOS=linux go build main.go
	zip trigger.zip main


# TODO
push:
	echo push


build: package push