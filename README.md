# My Infrastructure as Code Repository

This repository contains the Ansible and Terraform code that I use to provision my infrastructure.

## Ansible

The `ansible` directory contains the Ansible playbooks and roles that I use to configure my servers. To run the Ansible code, you need to have Ansible installed on your machine. You can install Ansible by running the following command:

```
sudo apt-get install ansible
```

Once you have Ansible installed, you can run the playbooks and roles by running the following command:

```
ansible-playbook playbook.yml
```

## Terraform

The `terraform` directory contains the Terraform code that I use to provision my infrastructure on AWS. To run the Terraform code, you need to have Terraform installed on your machine. You can install Terraform by downloading the binary from the Terraform website and adding it to your PATH.

Once you have Terraform installed, you can initialize the Terraform backend by running the following command:

```
terraform init
```

You can then apply the Terraform code by running the following command:

```
terraform apply
```

## Contributing

If you want to contribute to this repository, please fork the repository and submit a pull request.

## License

This repository is licensed under the MIT License. See the LICENSE file for more information.
