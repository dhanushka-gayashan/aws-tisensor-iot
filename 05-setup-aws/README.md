## Pre-Requisites
1. ***AWS IAM Identity Center***
   1. ***Enable*** `AWS IAM Identity Center`
   2. ***Customize*** `AWS Access Portal URL` (Ex: https://dhanukdg.awsapps.com/start)


## Post-Requisites
1. Configure ***IOT CORE Certificates*** in ***IOT Device*** 
2. Enable/Verify SSO User: 
   1. Login to AWS Console 
   2. Go to and ***AWS IAM Identity Center***
   3. Click on Created User's Name
   4. Click on ***Send email verification link***
   5. Login to provided email and active the User
   6. In Login page, select ***Forgot Password*** option to ***Set*** the password
      - username = "grafana"
      - password = "Grafana123!"
3. Follow the steps in `./rule-timestreamdb/dashboard/README.md` to create the ***Dashboard***


## Create Sample Mobile Number
Use `save_mobile_number.http` file


## Provision AWS Resource with Terraform

1. `Initiate` **Terraform**
   ```shell
   make tf_init
   ```

2. `Plan` **Terraform**
   ```shell
   make tf_plan
   ```

3. `Apply` **Terraform**
   ```shell
   make tf_apply
   ```

4. `Destroy` **Terraform**
   ```shell
   make tf_destroy
   ```

5. `Clean` **Environment**
   ```shell
   make tf_clean
   ```

## Sample Test Data

```json
{
  "timestamp": "2023-06-25T08:58:21.149Z",
  "device_label": "tisensor",
  "location": "office",
  "pressure": 1008,
  "accelerometer": {},
  "gyroscope": {},
  "magnetometer": {},
  "temperature": 0,
  "humidity": 0
}
```

```json
{
  "timestamp": "2023-06-25T08:58:21.491Z",
  "device_label": "tisensor",
  "location": "office",
  "pressure": 0,
  "accelerometer": {
    "x": 0.13,
    "y": 0.06,
    "z": 4.04
  },
  "gyroscope": {},
  "magnetometer": {},
  "temperature": 0,
  "humidity": 0
}
```


```json
{
  "timestamp": "2023-06-25T08:58:20.468Z",
  "device_label": "tisensor",
  "location": "office",
  "pressure": 0,
  "accelerometer": {},
  "gyroscope": {
    "x": -0.13,
    "y": 1.66,
    "z": 0.8
  },
  "magnetometer": {},
  "temperature": 0,
  "humidity": 0
}
```


```json
{
  "timestamp": "2023-06-25T08:58:20.468Z",
  "device_label": "tisensor",
  "location": "office",
  "pressure": 0,
  "accelerometer": {},
  "gyroscope": {},
  "magnetometer": {
    "x": 113.78,
    "y": -60.11,
    "z": 77.5
  },
  "temperature": 0,
  "humidity": 0
}
```


```json
{
  "timestamp": "2023-06-25T08:58:20.954Z",
  "device_label": "tisensor",
  "location": "office",
  "pressure": 0,
  "accelerometer": {},
  "gyroscope": {},
  "magnetometer": {},
  "temperature": 20.4,
  "humidity": 61.8
}
```
