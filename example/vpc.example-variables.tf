
/*
 | --
 | -- If you are using an IAM role as the AWS access mechanism then
 | -- pass it as in_role_arn commonly through an environment variable
 | -- named TF_VAR_in_role_arn in addition to the usual AWS access
 | -- key, secret key and default region parameters.
 | --
*/
variable in_role_arn {
    description = "The optional role arn to use if your AWS access mechanism is via IAM roles."
    default     = ""
    type        = string
}
