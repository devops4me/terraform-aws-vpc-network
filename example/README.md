
# Example | Create an AWS VPC Network

This example creates a VPC, subnets and the networking backbone to allow traffic to be routed in and also routed out to service endpoints on the internet. Let's first use docker then do the same thing with terraform installed on your machine.


## Docker | Create VPC Networks

With docker, you need not worry about which Terraform version is installed on your machine. All you need are your AWS access credentials.


```
docker build --rm --no-cache --tag devops4me/vpc-network .

### This Actually Works (But the next problem is - CAN WE DESTROY)
### ALSO this prompts  - we need to add -auto-approve to the docker file
docker run -i -e AWS_DEFAULT_REGION=eu-west-1 -e AWS_ACCESS_KEY_ID=XXXXXXXXXXXXX -e AWS_SECRET_ACCESS_KEY=XXXXXXX -e TF_VAR_in_role_arn=ZZZZZZZZZZZZ  -t devops4me/vpc-network apply






docker run -i -t devops4me/vpc-network \
    --env AWS_DEFAULT_REGION=eu-west-1 apply



git clone github.com/devops4me/terraform-aws-vpc-network
cd terraform-aws-vpc-network/example
docker build --rm --no-cache --tag devops4me/vpc-network .
docker images
docker run         \
    --detach       \
    --name vm.vpc  \
    --network host \
    --volume ${PWD}:/home/ubuntu \
    devops4me/vpc-network;
```


## How to Run the Example

```
# get module and go to example directory
git clone github.com/devops4me/terraform-aws-vpc-network
cd terraform-aws-vpc-network/example

# export access information
export TF_VAR_in_role_arn=<<role-arn>>
export AWS_ACCESS_KEY_ID=<<access-key-id>>
export AWS_SECRET_ACCESS_KEY=<<secret-access-key>>
export AWS_DEFAULT_REGION=<<region-key>>

# use terraform to bring up and tear down infastructure
terraform init
terraform providers
terraform apply -auto-approve
terraform show
terraform destroy -auto-approve
```

## Inputs

| Input Variable             | Type    | Description                                                   | Required?      |
|:-------------------------- |:-------:|:------------------------------------------------------------- |:--------------:|
| **in_role_arn**            | String  | Pass if using an IAM role as the AWS access mechanism.        | optional       |

### What is the role arn?

If you are using an IAM role as the AWS access mechanism then pass it as in_role_arn commonly through an environment variable named **TF_VAR_in_role_arn** in addition to the usual AWS access key, secret key and default region parameters.

Individuals and small businesses who don't have hundreds of AWS accounts can omit the variable and thanks to dynamic assignment the assume_role block will cease to exist.


### The AWS 5 VPC's Limit

The default VPC limit is just 5 and this test needs at least 10 so take yourself to the support section and request extension to say 25 - it will be done automatically in less than 5 minutes.

