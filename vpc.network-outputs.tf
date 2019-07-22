
################ ########################################### ########
################ Module [[[subnets]]] Output Variables List. ########
################ ########################################### ########

### ##################### ###
### [[output]] out_vpc_id ###
### ##################### ###

output out_vpc_id {

    description = "This (string) vpc_id is the ID of the VPC that has just been created."
    value       = "${aws_vpc.this_vpc.id}"
}


### ######################### ###
### [[output]] out_subnet_ids ###
### ######################### ###

output out_subnet_ids {

    description = "Every subnet ID in every availability zone of this VPC."
    value       = [ "${ aws_subnet.private.*.id }", "${ aws_subnet.public.*.id }" ]
}


### ################################# ###
### [[output]] out_private_subnet_ids ###
### ################################# ###

output out_private_subnet_ids {

    description = "The private subnet IDS in every availability zone of this VPC."
    value       = [ "${ aws_subnet.private.*.id }" ]
}


### ################################ ###
### [[output]] out_public_subnet_ids ###
### ################################ ###

output out_public_subnet_ids {

    description = "The public subnet IDS in every availability zone of this VPC."
    value       = [ "${aws_subnet.public.*.id}" ]
}


/*
 | --
 | -- IMPORTANT - DO NOT LET TERRAFORM BRING UP EC2 INSTANCES INSIDE PRIVATE
 | -- SUBNETS BEFORE (SLOW TO CREATE) NAT GATEWAYS ARE UP AND RUNNING.
 | --
 | -- Suppose systemd on bootup wants to get a rabbitmq docker image as
 | -- specified by a service unit file. Terraform will quickly bring up ec2
 | -- instances and then proceed to slowly create NAT gateways. To avoid
 | -- these types of bootup errors we must declare explicit dependencies to
 | -- delay ec2 creation until the private gateways and routes are ready.
 | --
*/
output out_outgoing_routes {

    description = "Aids creation of explicit dependency for instances brought up in private subnets."
    value       = "${aws_route.private.*.id}"
}
