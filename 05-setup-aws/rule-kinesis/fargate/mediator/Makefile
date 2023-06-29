install:
	go get github.com/gorilla/websocket
	go get github.com/aws/aws-sdk-go

# run locally
run:
	go run main.go

# run on docker locally
AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID>
AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY>
docker_run:
	docker build -t mediator .
	docker run -e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) -e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) mediator


# push image to aws ecr
ACCOUNT_ID=516867159723
REGION=us-east-1
REPO_NAME=mediator
IMAGE_TAG=latest
BUILD_NUMBER=1.0.3

login:
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com

build:
	docker build -t $(REPO_NAME):$(IMAGE_TAG) .

tag:
	docker tag $(REPO_NAME):$(IMAGE_TAG) $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(REPO_NAME):$(IMAGE_TAG)
	docker tag $(REPO_NAME):$(IMAGE_TAG) $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(REPO_NAME):$(BUILD_NUMBER)

push:
	docker push $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(REPO_NAME):$(IMAGE_TAG)
	docker push $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(REPO_NAME):$(BUILD_NUMBER)

build: login build tag push