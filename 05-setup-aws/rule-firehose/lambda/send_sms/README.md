#### Build package
```shell
make build
```


#### Test Payload - Send ***SMS SQS***
```json
{
  "Message": {
    "mobile": "+642102995529",
    "message": "HIGH PRESSURE"
  }
}
```