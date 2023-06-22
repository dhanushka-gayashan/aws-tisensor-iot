tf_init:
	terraform init

tf_validate:
	terraform validate

tf_plan:
	terraform init -upgrade
	terraform plan

tf_apply:
	terraform apply -auto-approve

tf_destroy:
	terraform destroy -auto-approve

tf_clean:
	rm -rf .terraform*
	rm -rf *.hcl
	rm -rf *.tfstate*