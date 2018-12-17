
locals
{
    ecosystem_name = "vpc-test"
}

/*
 | -- Zero parameter integration test.
 | -- Number of public and private subnets are expected 
 | -- to match the number of availability zones.
*/
module subnet-count-not-stated
{
    source = ".."
    in_ecosystem_name     = "${ local.ecosystem_name }"
    in_tag_timestamp      = "${ module.resource-tags.out_tag_timestamp }"
    in_tag_description    = "${ module.resource-tags.out_tag_description }"
}

module just-two-subnets
{
    source                 = ".."
    in_vpc_cidr            = "10.240.0.0/21"
    in_num_private_subnets = 2
    in_num_public_subnets  = 2
    in_subnets_max         = "7"

    in_ecosystem_name     = "${ local.ecosystem_name }-01"
    in_tag_timestamp      = "${ module.resource-tags.out_tag_timestamp }"
    in_tag_description    = "${ module.resource-tags.out_tag_description }"
}

module no-private-subnets
{
    source                 = ".."
    in_vpc_cidr            = "10.241.0.0/16"
    in_subnets_max         =  "4"
    in_num_private_subnets = 0
    in_num_public_subnets  = 2
    in_create_public_gateway = false

    in_ecosystem_name     = "${ local.ecosystem_name }-02"
    in_tag_timestamp      = "${ module.resource-tags.out_tag_timestamp }"
    in_tag_description    = "${ module.resource-tags.out_tag_description }"
}

module two-subnets-per-zone
{
    source                    = ".."
    in_vpc_cidr               = "10.242.0.0/16"
    in_num_private_subnets    = 6
    in_num_public_subnets     = 6
    in_create_public_gateway  = false
    in_create_private_gateway = false

    in_ecosystem_name     = "${ local.ecosystem_name }-03"
    in_tag_timestamp      = "${ module.resource-tags.out_tag_timestamp }"
    in_tag_description    = "${ module.resource-tags.out_tag_description }"
}

/*
 | --
 | -- Remember the AWS resource tags! Using this module, every
 | -- infrastructure component is tagged to tell you 5 things.
 | --
 | --   a) who (which IAM user) created the component
 | --   b) which eco-system instance is this component a part of
 | --   c) when (timestamp) was this component created
 | --   d) where (in which AWS region) was this component created
 | --   e) which eco-system class is this component a part of
 | --
*/
module resource-tags
{
    source = "github.com/devops4me/terraform-aws-resource-tags"
}

output subnet_ids_1{ value = "${module.subnet-count-not-stated.out_subnet_ids}" }
output private_subnet_ids_1{ value = "${module.subnet-count-not-stated.out_private_subnet_ids}" }
output public_subnet_ids_1{ value = "${module.subnet-count-not-stated.out_public_subnet_ids}" }

output subnet_ids_2{ value = "${module.just-two-subnets.out_subnet_ids}" }
output private_subnet_ids_2{ value = "${module.just-two-subnets.out_private_subnet_ids}" }
output public_subnet_ids_2{ value = "${module.just-two-subnets.out_public_subnet_ids}" }

output subnet_ids_3{ value = "${module.no-private-subnets.out_subnet_ids}" }
output private_subnet_ids_3{ value = "${module.no-private-subnets.out_private_subnet_ids}" }
output public_subnet_ids_3{ value = "${module.no-private-subnets.out_public_subnet_ids}" }

output subnet_ids_4{ value = "${module.two-subnets-per-zone.out_subnet_ids}" }
output private_subnet_ids_4{ value = "${module.two-subnets-per-zone.out_private_subnet_ids}" }
output public_subnet_ids_4{ value = "${module.two-subnets-per-zone.out_public_subnet_ids}" }
