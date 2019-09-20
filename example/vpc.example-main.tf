
/*
 | --
 | -- If you are using an IAM role as the AWS access mechanism then
 | -- pass it as in_role_arn commonly through an environment variable
 | -- named TF_VAR_in_role_arn in addition to the usual AWS access
 | -- key, secret key and default region parameters.
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


/*
 | --
 | -- Terraform will tag every significant resource allowing you to report and collate
 | --
 | --   [1] - all infrastructure in all environments dedicated to your app (ecosystem_name)
 | --   [2] - the infrastructure dedicated to this environment instance (timestamp)
 | --
*/
locals {
    ecosystem_name = "virtual-net"
    timestamp = formatdate( "YYMMDDhhmmss", timestamp() )
    date_time = formatdate( "EEEE DD-MMM-YY hh:mm:ss ZZZ", timestamp() )
    description = "was created by me on ${ local.date_time }."
}



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
