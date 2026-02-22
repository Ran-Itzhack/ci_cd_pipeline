## Run Terraform Basics

`terraform init -> terraform validate -> terraform plan -> terraform apply -> terraform destroy`

Now, open your terminal in that directory and follow the standard Terraform workflow.

1. Initialize, Bash: `terraform init`
This downloads the Docker provider plugin so Terraform can talk to your Docker engine.



2. `terraform fmt` - the Terraform CLI that automatically reformats your Terraform configuration files (.tf) to a canonical format and style.

3. `terraform validate`

4. Plan, Bash: `terraform plan`
- This shows you what Terraform intends to do. It will tell you it's going to build one image and create one container.


5. Apply, Bash: `terraform apply -auto-approve`
- This executes the plan. When prompted, type yes.

6. Destroy, Bash: `terraform destroy -auto-approve`


## Setting Input Variables 
- To manually set input variables for terraform plan and terraform apply 
- Set the Environment Variable in Shell: Set an environment variable in your shell using the prefix `TF_VAR_`name.

- Pass the file using the `-var-file` flag when running a Terraform command:
bash: 
- `https://developer.hashicorp.com/terraform/language/values/variables`

`terraform apply -var-file="production.tfvars" `
# or for terraform plan
`terraform plan -var-file="production.tfvars" `