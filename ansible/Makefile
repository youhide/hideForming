help:                             ## Show this help. Ex. $ make help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

toolbox-ubuntu:                   ## Runs the playbook for the toolbox-ubuntu environment. Ex. $ make toolbox-ubuntu
	@ansible-lint playbooks/toolbox-ubuntu.yml
	@ansible-playbook --diff -i environments/hosts playbooks/toolbox-ubuntu.yml -u ubuntu

cronbox:                          ## Runs the playbook for the cronbox environment. Ex. $ make cronbox
	@ansible-lint playbooks/cronbox.yml
	@ansible-playbook --diff -i environments/hosts playbooks/cronbox.yml -u root

terraform-agent:                  ## Runs the playbook for the terraform-agent environment. Ex. $ make terraform-agent
	@ansible-lint playbooks/terraform-agent.yml
	@ansible-playbook --diff -i environments/hosts playbooks/terraform-agent.yml -u root

legend-database:                  ## Runs the playbook for the legend-database environment. Ex. $ make legend-database
	@ansible-lint playbooks/legend-database.yml
	@ansible-playbook --diff -i environments/hosts playbooks/legend-database.yml -u root
