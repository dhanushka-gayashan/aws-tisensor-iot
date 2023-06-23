### Install require packages
```shell
make install
```


### Build executable package
```shell
make build
```


#### Test Payload - Send ***NOTIFICATION SQS***
```json
{
  "message": "HIGH PRESSURE",
  "date": "08:43AM on June 23, 2023"
}
```