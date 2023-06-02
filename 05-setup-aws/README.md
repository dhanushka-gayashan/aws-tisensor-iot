## Provision AWS Resource with Terraform

### Created Resources


### Terraform Commands
1. `Initiate` **Terraform**
```shell
terraform init
```

2. `Plan` **Terraform**
```shell
terraform init -upgrade

terraform plan
```

3. `Apply` **Terraform**
```shell
terraform apply -auto-approve
```

4. `Destroy` **Terraform**
```shell
terraform destroy -auto-approve
```

5. `Clean` **Environment**
```shell
rm -rf .terraform
rm -rf *.hcl
rm -rf *.tfstate*
```