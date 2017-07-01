# Rancher scalability test

Small and simple scripts to add hosts/stacks to a [Rancher](https://github.com/rancher) server using [rancher cli](https://github.com/rancher/cli).

* add_stacks.sh

Adds a simple nginx stacks configured in nginx/ with random the the pre-configured rancher-cli. Takes number of stacks as an argument.

* add_aws_hosts.sh

Uses rancher-cli to add create and add hosts on AWS. Takes the number of hosts to add as an argument. Requires $AWS_EC2_KEY and $AWS_EC2_SECRET_KEY environment variables to be set. $AWS_EC2_REGION $AWS_EC2_ZONE are pre-set in the script and you can override them by exporting them. Other options can be modified by editing the script.

* nginx/

Very simple stack based on 2 nginx container. No services.
