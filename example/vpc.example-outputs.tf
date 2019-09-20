
### ########################### ###
### Example VPC Network Outputs ###
### ########################### ###

output subnet_ids_1 {
    value = module.vpc-net.out_subnet_ids
}

output private_subnet_ids_1 {
    value = module.vpc-net.out_private_subnet_ids
}

output public_subnet_ids_1 {
    value = module.vpc-net.out_public_subnet_ids
}

output subnet_ids_2 {
    value = module.two-pub-priv-subnets.out_subnet_ids
}

output private_subnet_ids_2 {
    value = module.two-pub-priv-subnets.out_private_subnet_ids
}

output public_subnet_ids_2 {
    value = module.two-pub-priv-subnets.out_public_subnet_ids
}

output subnet_ids_3 {
    value = module.no-private-subnets.out_subnet_ids
}

output private_subnet_ids_3 {
    value = module.no-private-subnets.out_private_subnet_ids
}

output public_subnet_ids_3 {
    value = module.no-private-subnets.out_public_subnet_ids
}
