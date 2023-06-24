## Pre-Requisites
1. ***AWS IAM Identity Center***
   1. ***Enable*** `AWS IAM Identity Center`
   2. ***Customize*** `AWS Access Portal URL`


## Post-Requisites
1. Configure ***IOT CORE Certificates*** in ***IOT Device*** 
2. Enable/Verify SSO User: 
   1. Login to AWS Console 
   2. Go to and ***AWS IAM Identity Center***
   3. Click on Created User's Name
   4. Click on ***Send email verification link***
   5. Login to provided email and active the User
   6. Select ***Forgot Password*** option to ***Reset*** the password
      - username = "grafana"
      - password = "Grafana123!"


## Follow the steps in `.rule-timestreamdb/dashboard/README.md` to create the ***Dashboard***


## Provision AWS Resource with Terraform

### Terraform Commands
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