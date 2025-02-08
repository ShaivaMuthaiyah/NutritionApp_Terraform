# CookSmart 

These are the terraform files for the "CookSmart" application that i developed.

## Description

CookSmart is an application that allows users to input body metrics, diet preferences and other information 
to receive an analysis dashboard as well as a custom diet plan. The app is completely serverless and runs
using various services such as EKS, S3, Route 53, VPC etc. An overall architecture diagram of the project
is given below. (Note: The S3 bucket storing blog data is not part of the terraform configuration currently 
due to some data being added externally through an admin panel and not automatically)

![overall_architecture](images/cloud_arch.png)


## Getting Started

### Dependencies/Requirements

* Have terraform installed
* Have the AWS CLI, Helm, Kubernetes installed
* Be logged in using 'aws config' with a user having required permissions
* Make sure the "terraform_user"
* Create a secrets file called secrets.tfvars with the following:
    * aws_access_key = "<your aws access key here>"
    * aws_secret_key = "<your secret access key here>"
    * root_arn = "arn:aws:iam::yourawsaccountid:root"
    * terraform_user_id = "<user id of the IAM user creating infra using terraform>"
    * terraform_user_arn = "arn:aws:iam::yourawsaccountid:user/terraform_user"


### Installing

Since infrastructure is managed using terraform the setting up process is very simple.

### Creating the Infrastructure

```
terraform init
terraform plan -var-file="secrets.tfvars"
terraform apply -var-file="secrets.tfvars"

```

### Destroying the Infrastructure

Refer the help section incase of issues destroying the infrastructure.

```
terraform destroy -auto-approve -var-file="secrets.tfvars"

```

## Help

Some common errors are listed below

* Timeout while destroying the EKS Cluster due to resources still running in the nutrition namespace: 
    * In this case delete all resources from that namespace. If the problems still persist remove the namespace from the
    state list and delete it again

```
terraform state rm kubernetes_namespace.nutrition_namespace
terraform destroy -auto-approve -var-file="secrets.tfvars"

```

* Timeout while destroying Cloud Watch agent inside the EKS Cluster: 
    * Similar to the previous solution delete all the resources from that namespace and if it persists just remove it from
    the state list after running the command:


```
terraform state list
terraform state rm  <item name>
terraform destroy -auto-approve -var-file="secrets.tfvars"

```

* Load balancer/ingress deplaying the deletion process:
    * In this case just delete the load balancer from the namespace using kubernetes commands.



## Authors

Contributors names and contact info


## Version History



## License



## Acknowledgments

Inspiration, code snippets, etc.
* [awesome-readme](https://github.com/matiassingers/awesome-readme)

