
################ ########################################## ########
################ Module [[[subnets]]] Input Variables List. ########
################ ########################################## ########

### ######################## ###
### [[variable]] in_vpc_cidr ###
### ######################## ###

variable in_vpc_cidr
{
    description = "The CIDr block defining the range of IP addresses allocated to this VPC."
    default     = "10.42.0.0/16"
}


### ################################### ###
### [[variable]] in_num_private_subnets ###
### ################################### ###

variable in_num_private_subnets
{
    description = "The number of private subnets to create (defaults to 3 if not specified)."
    default     = "3"
}


### ################################## ###
### [[variable]] in_num_public_subnets ###
### ################################## ###

variable in_num_public_subnets
{
    description = "The number of public subnets to create (defaults to 3 if not specified)."
    default     = "3"
}


### ########################### ###
### [[variable]] in_subnets_max ###
### ########################### ###

variable in_subnets_max
{
    description = "Two to the power of in_subnets_max is the maximum number of subnets carvable from VPC described by in_vpc_cidr."
    default     = "4"
}


### ##################################### ###
### [[variable]] in_create_public_gateway ###
### ##################################### ###

variable in_create_public_gateway
{
    description = "An internet gateway and route is created unless this variable is supplied as false."
    default     = true
}


### ###################################### ###
### [[variable]] in_create_private_gateway ###
### ###################################### ###

variable in_create_private_gateway
{
    description = "If private subnets exist an EIP, a NAT gateway, route and subnet association are created unless this variable is supplied as false."
    default     = true
}


### ######################### ###
### [[variable]] in_ecosystem ###
### ######################### ###

variable in_ecosystem
{
    description = "The name of the class of ecosystem being built like kubernetes-cluster or elasticsearch-db."
    default     = "eco-system"
}


################ ################################################### ########
################ The key environment specific data source variables. ########
################ ################################################### ########

### ############################### ###
### [[data]] aws_availability_zones ###
### ############################### ###

data aws_availability_zones with {}

