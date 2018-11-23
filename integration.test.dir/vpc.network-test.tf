

locals
{
    ecosystem_id = "vpc-test"
}

/*
 | -- Zero parameter integration test.
 | -- Number of public and private subnets are expected 
 | -- to match the number of availability zones.
*/
module subnet-count-not-stated
{
    source = ".."
}

module just-two-subnets
{
    source                 = ".."
    in_vpc_cidr            = "10.240.0.0/21"
    in_num_private_subnets = 2
    in_num_public_subnets  = 2
    in_subnets_max         = "7"
    in_ecosystem           = "${local.ecosystem_id}-04"
}

module no-private-subnets
{
    source                 = ".."
    in_vpc_cidr            = "10.241.0.0/16"
    in_subnets_max         =  "4"
    in_num_private_subnets = 0
    in_num_public_subnets  = 2
    in_create_public_gateway = false
    in_ecosystem           = "${local.ecosystem_id}-05"
}

module two-subnets-per-zone
{
    source                    = ".."
    in_vpc_cidr               = "10.242.0.0/16"
    in_num_private_subnets    = 6
    in_num_public_subnets     = 6
    in_create_public_gateway  = false
    in_create_private_gateway = false
    in_ecosystem              = "${local.ecosystem_id}-08"
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
