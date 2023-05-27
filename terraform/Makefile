TERRAFORM_VERSION := $(shell terraform --version | head -n 1 | sed -e 's/^Terraform v\(.*\)$$/\1/')
TERRAFORM_REQUIRED_VERSION := "1.4.6"

help:           ## Checks terraform version
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

check:          ## Checks terraform version
	@echo "Checking terraform version... expecting version [${TERRAFORM_REQUIRED_VERSION}], found [${TERRAFORM_VERSION}]"

init: check     ## Initialize terraform. Ex. $ make init
	terraform init --upgrade

validate: check ## Does a terraform validate. Ex. $ make validate
	@terraform validate	

plan: check     ## Run terraform plan. Ex. $ make tf plan
	@terraform fmt
	@tflint --init
	@tflint --chdir .
	@tfsec --exclude-downloaded-modules .
	@echo "Pulling the required modules..."
	@terraform get
	@terraform plan
  
apply: check    ## run an apply against an env. Ex. $ make apply
	@terraform show -no-color
	@terraform apply -auto-approve

clean:          ## Cleans up terraform files. Ex. $ make clean
	test -f $(terraform-plan*) && rm -f terraform-plan*
	test -d $(.terraform) && rm -rf .terraform
	test -f $(*.tfstate) && rm -f *.tfstate
	test -f $(.terraform.lock.hcl) && rm -f .terraform.lock.hcl
