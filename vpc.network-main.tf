
/*
 | --
 | -- The Amazon VPC (virtual private cloud) is the container of choice
 | -- for subsystems and sometimes eco-systems.
 | --
 | -- The VPC is tied to a region (like London, Paris or Dublin) but
 | -- spans the (two to four) availability zones (data centres) within
 | -- the geographical auspices of the region.
 | --
*/
resource aws_vpc this_vpc
{
    cidr_block   = "${ var.in_vpc_cidr }"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags
    {
        Name   = "vpc-${ var.in_ecosystem }-${ module.ecosys.out_stamp }"
        Class = "${ var.in_ecosystem }"
        Instance = "${ var.in_ecosystem }-${ module.ecosys.out_stamp }"
        Desc   = "This vpc for ${ var.in_ecosystem } ${ module.ecosys.out_history_note }"
    }
}


/*
 | -- Round robin card dealing distribution of private subnets
 | -- across availability zones is done here.
 | --
 | -- The modulus functionality is silently implemented by
 | -- "element" which rotates back to the first zone if the
 | -- subnet count exceeds the zone count.
*/
resource aws_subnet private
{
    count = "${ var.in_num_private_subnets }"

    cidr_block        = "${ cidrsubnet( var.in_vpc_cidr, var.in_subnets_max, count.index ) }"
    availability_zone = "${ element( data.aws_availability_zones.with.names, count.index ) }"
    vpc_id            = "${ aws_vpc.this_vpc.id }"

    map_public_ip_on_launch = false

    tags
    {
        Name     = "subnet-${ var.in_ecosystem }-${ module.ecosys.out_stamp }-${ format( "%02d", count.index + 1 ) }-az${ element( split( "-", element( data.aws_availability_zones.with.names, count.index ) ), 2 ) }-x"
        Class    = "${ var.in_ecosystem }"
        Instance = "${ var.in_ecosystem }-${ module.ecosys.out_stamp }"
        Desc     = "Private subnet no.${ count.index + 1 } within availability zone ${ element( split( "-", element( data.aws_availability_zones.with.names, count.index ) ), 2 ) } ${ module.ecosys.out_history_note }"
    }

}


/*
 | -- Round robin card dealing distribution of public subnets
 | -- across availability zones is done here.
 | --
 | -- The modulus functionality is silently implemented by
 | -- "element" which rotates back to the first zone if the
 | -- subnet count exceeds the zone count.
*/
resource aws_subnet public
{
    count = "${ var.in_num_public_subnets }"

    cidr_block        = "${ cidrsubnet( var.in_vpc_cidr, var.in_subnets_max, var.in_num_private_subnets + count.index ) }"
    availability_zone = "${ element( data.aws_availability_zones.with.names, count.index ) }"
    vpc_id            = "${ aws_vpc.this_vpc.id }"

    map_public_ip_on_launch = true

    tags
    {
        Name     = "subnet-${ var.in_ecosystem }-${ module.ecosys.out_stamp }-${ format( "%02d", var.in_num_private_subnets + count.index + 1 ) }-az${ element( split( "-", element( data.aws_availability_zones.with.names, count.index ) ), 2 ) }-o"
        Class    = "${ var.in_ecosystem }"
        Instance = "${ var.in_ecosystem }-${ module.ecosys.out_stamp }"
        Desc     = "Public subnet no.${ var.in_num_private_subnets + count.index + 1 } within availability zone ${ element( split( "-", element( data.aws_availability_zones.with.names, count.index ) ), 2 ) } ${ module.ecosys.out_history_note }"
    }

}


/*
 | --
 | -- Almost all services make outgoing (egress) connections to the internet
 | -- regardless whether those services are in public or private subnets. So
 | -- an internet gateway and route are always created unless the variable
 | -- in_create_public_gateway is passed in and set to false.
 | --
 | -- The availability and scaleability of an internet gateway is taken care
 | -- of behind the scenes thus we only need one in a VPC unlike NAT gateways
 | -- which must be created per availability zone.
 | --
*/
resource aws_internet_gateway this
{
    count  = "${ var.in_create_public_gateway }"

    vpc_id = "${ aws_vpc.this_vpc.id }"

    tags
    {
        Name  = "net-gateway-${ var.in_ecosystem }-${ module.ecosys.out_stamp }"
        Class = "${ var.in_ecosystem }"
        Instance = "${ var.in_ecosystem }-${ module.ecosys.out_stamp }"
        Desc  = "This internet gateway for ${ var.in_ecosystem } ${ module.ecosys.out_history_note }"
    }
}


/*
 | --
 | -- Almost all services make outgoing (egress) connections to the internet
 | -- regardless whether those services are in public or private subnets. So
 | -- an internet gateway and route are always created unless the variable
 | -- in_create_public_gateway is passed in and set to false.
 | --
 | -- This route through the internet gateway is created against the VPC's
 | -- default route table. The destination is set as 0.0.0.0/0 (everywhere).
 | --
*/
resource aws_route public
{
    count  = "${ var.in_create_public_gateway }"

    route_table_id         = "${ aws_vpc.this_vpc.default_route_table_id }"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = "${ aws_internet_gateway.this.id }"
}


/*
 | --
 | -- This elastic IP address is presented to the NAT
 | -- (network address translator) and is only required
 | -- (like the NAT) when private subnets need to connect
 | -- externally to a publicly addressable endpoint.
 | --
 | -- Every availability zone (and public/private subnet
 | -- pairing) will have its own NAT gateway and hence
 | -- its own elastic IP address.
 | --
 | -- This elastic IP is created if at least 1 private subnet
 | -- exists and in_create_private_gateway is true.
 | --
*/
resource aws_eip nat_gw_ip
{
    count = "${ var.in_num_private_subnets * var.in_create_private_gateway }"

    vpc        = true
    depends_on = [ "aws_internet_gateway.this" ]

    tags
    {
        Name  = "elastic-ip-${ var.in_ecosystem }-${ module.ecosys.out_stamp }"
        Class = "${ var.in_ecosystem }"
        Instance = "${ var.in_ecosystem }-${ module.ecosys.out_stamp }"
        Desc  = "This elastic IP in public subnet ${ element( aws_subnet.public.*.id, count.index ) } for ${ var.in_ecosystem } ${ module.ecosys.out_history_note }"
    }
}


/*
 | --
 | -- This NAT (network address translator) gateway lives
 | -- to route traffic from the private subnet in its availability
 | -- zone to external networks and the internet at large.
 | --
 | -- IMPORTANT - DO NOT LET TERRAFORM BRING UP EC2 INSTANCES INSIDE PRIVATE
 | -- SUBNETS BEFORE (SLOW TO CREATE) NAT GATEWAYS ARE UP AND RUNNING.
 | -- (see comment against definition of resource.aws_route.private).
 | --
 | -- It does this from within a public subnet and requires
 | -- an internet gateway and an elastic IP address.
 | --
 | -- It uses the elastic IP address to wrap outgoing traffic
 | -- from the private subnet and then unwraps the returning
 | -- response sending it back to the originating private service.
 | --
 | -- Every availability zone (and public/private subnet
 | -- pairing) will have its own NAT gateway and hence
 | -- its own elastic IP address.
 | --
*/
resource aws_nat_gateway this
{
    count = "${ var.in_num_private_subnets * var.in_create_private_gateway }"

    allocation_id = "${ element( aws_eip.nat_gw_ip.*.id, count.index ) }"
    subnet_id     = "${ element( aws_subnet.public.*.id, count.index ) }"
    depends_on    = [ "aws_internet_gateway.this" ]

    tags
    {
        Name     = "nat-gateway-${ var.in_ecosystem }-${ module.ecosys.out_stamp }"
        Class    = "${ var.in_ecosystem }"
        Instance = "${ var.in_ecosystem }-${ module.ecosys.out_stamp }"
        Desc     = "This NAT gateway in public subnet ${ element( aws_subnet.public.*.id, count.index ) } for ${ var.in_ecosystem } ${ module.ecosys.out_history_note }"
    }
}


/*
 | --
 | -- These route tables are required for holding private routes
 | -- so that private network interfaces (in the private subnets)
 | -- can initiate connections to the internet.
 | --
*/
resource aws_route_table private
{
    count = "${ var.in_num_private_subnets * var.in_create_private_gateway }"

    vpc_id = "${ aws_vpc.this_vpc.id }"

    tags
    {
        Name     = "route-table-${ var.in_ecosystem }-${ module.ecosys.out_stamp }"
        Class    = "${ var.in_ecosystem }"
        Instance = "${ var.in_ecosystem }-${ module.ecosys.out_stamp }"
        Desc     = "This route table associated with private subnet ${ element( aws_subnet.private.*.id, count.index ) } for ${ var.in_ecosystem } ${ module.ecosys.out_history_note }"
    }
}


/*
 | --
 | -- These routes go into the newly created private route tables and
 | -- are designed to allow network interfaces (in the private subnets)
 | -- to initiate connections to the internet via its corresponding nat gateway
 | -- in a sister public subnet in the same availability zone.
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
resource aws_route private
{
    count = "${ var.in_num_private_subnets * var.in_create_private_gateway }"

    route_table_id = "${ element( aws_route_table.private.*.id, count.index ) }"
    nat_gateway_id = "${ element( aws_nat_gateway.this.*.id, count.index ) }"

    destination_cidr_block = "0.0.0.0/0"
}


/*
 | --
 | -- These route table associations per each availability zone binds
 | --
 | --   a) the route inside the route table that ...
 | --   b) goes to the NAT gateway inside the public subnet with ...
 | --   c) the private subnet that has ...
 | --   d) private interfaces that need to connect to the internet
 | --
*/
resource aws_route_table_association private
{
    count = "${ var.in_num_private_subnets * var.in_create_private_gateway }"

    subnet_id      = "${ element( aws_subnet.private.*.id, count.index ) }"
    route_table_id = "${ element( aws_route_table.private.*.id, count.index ) }"
}



resource aws_flow_log troubleshoot
{
    vpc_id               = "${ aws_vpc.this_vpc.id }"
    log_destination      = "${ data.aws_s3_bucket.flow_logs.arn }"
    log_destination_type = "s3"
    traffic_type         = "ALL"
}


data aws_s3_bucket flow_logs
{
    bucket = "vpc.network.flow.logs"
}





/*
resource aws_s3_bucket flowlogs
{
    bucket = "vpc.network.flow.logs"
    acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "log_bucket" {
  bucket        = "${local.log_bucket_name}"
  policy        = "${data.aws_iam_policy_document.bucket_policy.json}"
  force_destroy = true
  tags          = "${local.tags}"

  lifecycle_rule {
    id      = "log-expiration"
    enabled = "true"

    expiration {
      days = "7"
    }
  }
}
*/


/*
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid       = "AllowToPutLoadBalancerLogsToS3Bucket"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.log_bucket_name}/${var.log_location_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_elb_service_account.main.id}:root"]
    }
  }
}
*/


### ################# ###
### [[module]] ecosys ###
### ################# ###

module ecosys
{
    source = "github.com/devops4me/terraform-aws-stamps"
}
