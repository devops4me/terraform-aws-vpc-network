
# Create VPC and Subnets in Availability Zones

This module's **default behaviour** is to create a VPC and then **create one private and one public subnet per availability zone** in the VPC's region. In Frankfurt 6 subnets would be created as there are 3 availability zones.

## Module Usage

    module vpc-network
    {
        source                 = "devops4me/vpc-network/aws"
        version                = "1.0.2"
        in_vpc_cidr            = "10.245.0.0/16"
        in_num_private_subnets = 6
        in_num_public_subnets  = 3
    }

The most common use case is to specify the VPC Cidr, the number of public and private subnets.


---


## [Run the Example](https://github.com/devops4me/terraform-aws-vpc-network/tree/master/example)

You can run the example to see this module create a number of VPCs with varying attributes such as the number of private/public subnets.

## Module Inputs

| Input Variable             | Type    | Description                                                   | Default        |
|:-------------------------- |:-------:|:------------------------------------------------------------- |:--------------:|
| **in_vpc_cidr**            | String  | The VPC's Cidr defining the range of available IP addresses   | 10.42.0.0/16   |
| **in_num_private_subnets** | Integer | Number of private subnets to create across availability zones | 3              |
| **in_num_public_subnets**  | Integer | Number of public subnets to create across availability zones. If one or more an internet gateway and route to the internet will be created regardless of the value of the in_create_gateway boolean variable. | 3 |
| **in_create_gateway**      | Boolean | If set to true an internet gateway and route will be created even when no public subnets are requested. | false |
| **[in_subnets_max](https://www.devopswiki.co.uk/vpc/network-cidr)**         | Integer | 2 to the power of this is the max number of carvable subnets  | 4 (16 subnets) |
| **in_ecosystem**           | String  | the class name of the ecosystem being built here              | eco-system     |

### Resource Tag Inputs

Most organisations have a mandatory set of tags that must be placed on AWS resources for cost and billing reports. Typically they denote owners and specify whether environments are prod or non-prod.

| Input Variable    | Variable Description | Input Example
|:----------------- |:-------------------- |:----- |
**`in_ecosystem`** | the ecosystem (environment) name these resources belong to | **`my-app-test`** or **`kubernetes-cluster`**
**`in_timestamp`** | the timestamp in resource names helps you identify which environment instance resources belong to | **`1911021435`** as **`$(date +%y%m%d%H%M%S)`**
**`in_description`** | a human readable description usually stating who is creating the resource and when and where | "was created by $USER@$HOSTNAME on $(date)."

Try **`echo $(date +%y%m%d%H%M%S)`** to check your timestamp and **`echo "was created by $USER@$HOSTNAME on $(date)."`** to check your description. Here is how you can send these values to terraform.

```
$ export TF_VAR_in_timestamp=$(date +%y%m%d%H%M%S)
$ export TF_VAR_in_description="was created by $USER@$HOSTNAME on $(date)."
```


---


## subnets into availability zones | round robin

You can create **more or less subnets** than there are availability zones in the VPC's region. You can ask for **6 private subnets** in a **3 availability zone region**. The subnets are distributed into the availability zones like dealing a deck of cards.

Every permutation of subnets and availability zones is catered for so you can demand

- **less subnets** than availability zones (so some won't get any)
- a subnet count that is an **exact multiple** of the zone count (equality reigns)
- that **no subnets** (public and/or private) get created
- nothing - and each availability zone will get one public and one private subnet


---


## internet gateway and route

This module **senses** whether you wish to **create an internet gateway** (in) and a route (out) to the internet.

If **in_num_public_subnets is greater than zero** it automatically creates an internet gateway and a route along with the public subnets. This behaviour can be switched off by setting **in_ignore_public** to true.


---


## output variables

Here are the most popular **output variables** exported from this VPC and subnet creating module.

| Exported | Type | Example | Comment |
|:-------- |:---- |:------- |:------- |
**out_vpc_id** | String | vpc-1234567890 | the **VPC id** of the just-created VPC
**out_rtb_id** | String | "rtb-2468013579" | ID of the VPC's default route table
**out_subnet_ids** | List of Strings | [ "subnet-545123498798345", "subnet-83507325124987" ] | list of **all private and public** subnet ids
**out_private_subnet_ids** | List of Strings | [ "subnet-545123498798345", "subnet-83507325124987" ] | list of **private** subnet ids
**out_public_subnet_ids** | List of Strings |  [ "subnet-945873408204034", "subnet-8940202943031" ] | list of **public** subnet ids


---


## Resources Created

This module houses your infrastructure within a secure VPC and it creates the networking resources for routing traffic to your services and conversely enabling your services to access the internet. This module creates

- a VPC (virtual private cloud)
- subnets within the VPC across one or more availability zones
- an **internet gateway** unless **`in_num_public_subnets`** is zero
- an **elastic IP address** unless **`in_num_public_subnets`** is zero
- a **nat gateway** attached to public subnets for routing outgoing traffic
- **route tables** along with the necessary public and private routes
- **associations** that bind subnets to route tables

The subnets are dished out across availability zones in a round robin fashion. You can request less, the same or more (private/public) subnets than there are availability zones.

