
# Terraform Docker Example | Create an AWS VPC Network

This example creates a VPC, subnets and the networking backbone to allow traffic to be routed in and also routed out to service endpoints on the internet.

### Step 1 | git clone into docker volume

First we create a docker volume (called **`vol.tfstate`**) and add the terraform module code to it by way of an **alpine git** container.

```
docker volume create vol.tfstate
docker run --interactive \
           --tty         \
	   --rm          \
	   --volume vol.tfstate:/terraform-work \
	   alpine/git \
	   clone https://github.com/devops4me/terraform-aws-vpc-network /terraform-work
sudo ls -lah /var/lib/docker/volumes/vol.tfstate/_data
```

**verify** - when you list the files in the container you will see the terraform module's contents there.


### Step 2 | terraform init via docker

As our volume contains the terraform module code from git we are now ready to perform a terraform init. We use the **[devops4me/terraform container](https://cloud.docker.com/repository/docker/devops4me/terraform/general)** container which adds a VOLUME mapping to the **[hashicorp/terraform](https://hub.docker.com/r/hashicorp/terraform/)** container at the **`/terraform-work`** location.

```
docker run --interactive \
           --tty \
	   --rm \
	   --name vm.terraform \
	   --volume vol.tfstate:/terraform-work \
	   devops4me/terraform init example
sudo ls -lah /var/lib/docker/volumes/vol.tfstate/_data
```

**verify** - the directory listing now contains a **`.terraform`** directory.



### Step 3 | terraform apply via docker

At last we can run the terraform apply. Provide a **role arn** only if your organization works with roles alongside the other 3 AWS authentication keys.

```
docker run --interactive \
           --tty \
	   --rm \
	   --name vm.terraform \
	   --env AWS_DEFAULT_REGION=<<aws-region-key>> \
	   --env AWS_ACCESS_KEY_ID=<<aws-access-key>> \
	   --env AWS_SECRET_ACCESS_KEY=<<aws-secret-key>> \
	   --env TF_VAR_in_role_arn=<<aws-role-arn>> \
	   --volume vol.tfstate:/terraform-work \
	   devops4me/terraform apply -auto-approve example
sudo ls -lah /var/lib/docker/volumes/vol.tfstate/_data
```

**verify** - the **docker volume** now has a **tfstate file** which documents the state of your infrastructure after terraform apply.


### Step 4 | terraform destroy via docker

After running plan and apply either once or multiple times you may feel the need to **`terraform destroy`** the infrastructure.

```
docker run --interactive \
           --tty \
	   --rm \
	   --name vm.terraform \
	   --env AWS_DEFAULT_REGION=<<aws-region-key>> \
	   --env AWS_ACCESS_KEY_ID=<<aws-access-key>> \
	   --env AWS_SECRET_ACCESS_KEY=<<aws-secret-key>> \
	   --env TF_VAR_in_role_arn=<<aws-role-arn>> \
	   --volume vol.tfstate:/terraform-work \
	   devops4me/terraform destroy -auto-approve example
sudo ls -lah /var/lib/docker/volumes/vol.tfstate/_data
```

**verify** - check your AWS console and also note that the volume now has a **tfstate backup file** created by terraform.
