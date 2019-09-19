
### #################### ###
### Example VPC Networks ###
### #################### ###

module vpc-net {

    source = "./.."
    in_ecosystem   = "${ local.ecosystem_name }-00"
    in_timestamp   = local.timestamp
    in_description = local.description
}


module two-pub-priv-subnets {

    source                 = "./.."
    in_vpc_cidr            = "10.240.0.0/21"
    in_num_private_subnets = 2
    in_num_public_subnets  = 2
    in_subnets_max         = "7"

    in_ecosystem   = "${ local.ecosystem_name }-01"
    in_timestamp   = local.timestamp
    in_description = local.description
}


module no-private-subnets {

    source                 = "./.."
    in_vpc_cidr            = "10.241.0.0/16"
    in_subnets_max         =  "4"
    in_num_private_subnets = 0
    in_num_public_subnets  = 2
    in_create_public_gateway = false
    in_create_private_gateway = false

    in_ecosystem   = "${ local.ecosystem_name }-02"
    in_timestamp   = local.timestamp
    in_description = local.description
}


### ########################### ###
### Example VPC Network Outputs ###
### ########################### ###

output subnet_ids_1{ value = module.vpc-net.out_subnet_ids }
output private_subnet_ids_1{ value = module.vpc-net.out_private_subnet_ids }
output public_subnet_ids_1{ value = module.vpc-net.out_public_subnet_ids }

output subnet_ids_2{ value = module.two-pub-priv-subnets.out_subnet_ids }
output private_subnet_ids_2{ value = module.two-pub-priv-subnets.out_private_subnet_ids }
output public_subnet_ids_2{ value = module.two-pub-priv-subnets.out_public_subnet_ids }

output subnet_ids_3{ value = module.no-private-subnets.out_subnet_ids }
output private_subnet_ids_3{ value = module.no-private-subnets.out_private_subnet_ids }
output public_subnet_ids_3{ value = module.no-private-subnets.out_public_subnet_ids }


/*
 | --
 | -- If you are using an IAM role as the AWS access mechanism then
 | -- pass it as in_role_arn commonly through an environment variable
 | -- named TF_VAR_in_role_arn in addition to the usual AWS access
 | -- key, secret key and default region parameters.
 | --
 | -- Individuals and small businesses without hundreds of AWS accounts
 | -- can omit the in_role_arn variable. and thanks to dynamic assignment
 | --
*/
provider aws {
    dynamic assume_role {
        for_each = length( var.in_role_arn ) > 0 ? [ var.in_role_arn ] : [] 
        content {
            role_arn = assume_role.value
	}
    }
}

variable in_role_arn {
    description = "The Role ARN to use when we assume role to implement the provisioning."
    default = ""
}


/*
 | --
 | -- ### ############# ###
 | -- ### Resource Tags ###
 | -- ### ############# ###
 | --
 | -- Terraform will tag every significant resource allowing you to report and collate
 | --
 | --   [1] - all infrastructure in all environments dedicated to your app (ecosystem_name)
 | --   [2] - the infrastructure dedicated to this environment instance (timestamp)
 | --
 | -- The human readable description reveals the when, where and what of the infrastructure.
 | --
*/
locals {
    ecosystem_name = "virtual-net"
    timestamp = formatdate( "YYMMDDhhmmss", timestamp() )
    date_time = formatdate( "EEEE DD-MMM-YY hh:mm:ss ZZZ", timestamp() )
    description = "was created by me on ${ local.date_time }."
}
