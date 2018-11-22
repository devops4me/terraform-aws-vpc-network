
# --->
# ---> Going with Ubuntu's Long Term Support (lts)
# ---> version which is currently 18.04.
# --->

FROM ubuntu:18.04


# --->
# ---> Assume the root user and install git, terraform,
# ---> a time zone manipulator and pythonic tools for
# ---> testing the AWS based infrastructure.
# --->

USER root

RUN apt-get update && apt-get --assume-yes install -qq -o=Dpkg::Use-Pty=0 \
      curl  \
      git   \
      tree  \
      unzip


# --->
# ---> The documentation here explains the makeup of the
# ---> powerful useradd command.
# --->
# ---> https://linux.die.net/man/8/useradd
# --->

RUN useradd --home /home/tester --create-home --shell /bin/bash --gid root tester


# --->
# ---> Install the Terraform binary.
# --->

RUN \
    curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.11.9/terraform_0.11.9_linux_amd64.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    chmod a+x /usr/local/bin/terraform         && \
    rm /tmp/terraform.zip                      && \
    terraform --version


# --->
# ---> As tester, we initialize terraform ready
# ---> for the apply command that will begin the
# ---> process of creating infrastructure.
# --->

USER tester
WORKDIR /home/tester
