
# Example | Creating a VPC Network

This example creates a VPC, subnets and the networking backbone to allow traffic to be routed in and also routed out to service endpoints on the internet.

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
terraform apply
terraform destroy
```

## Inputs

| Input Variable             | Type    | Description                                                   | Required?      |
|:-------------------------- |:-------:|:------------------------------------------------------------- |:--------------:|
| **in_role_arn**            | String  | Pass if using an IAM role as the AWS access mechanism.        | optional       |

### What is the role arn?

If you are using an IAM role as the AWS access mechanism then pass it as in_role_arn commonly through an environment variable named **TF_VAR_in_role_arn** in addition to the usual AWS access key, secret key and default region parameters.

Individuals and small businesses who don't have hundreds of AWS accounts can omit the variable and thanks to dynamic assignment the assume_role block will cease to exist.


## Related Modules

