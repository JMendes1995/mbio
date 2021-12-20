# MBio task

## How to setup the cluster
<b>Note: all nodes has elastic ip's in order to pull the packages from internet however the ingress requests are only allowed for private network</b>

All modules in `terraform-modules` folder are completely independent with independent state files to allow concurrent executions.

1 - create s3 bucket to store our tf state to use as terraform backend.

```
cd /mbio/account-config
terraform init
terraform apply
```

2 - Provision base infrastructure for task 1 and task 2

The base infra contains for task 1 and task 2 vpc:
* VPC
* 3 subnets(1 per az)
* 3 route tables (1 per subnet)
* 1 bastion server (used as proxy to reach the other nodes via private network)
* Network interface
* bastion security group
* elastic ip to connect from my pc and get the packages from internet.

to enable the connectivity between vpc's was created a vpc peering and routing rules in all routing tables.

```
cd /mbio/terraform-modules/base
terraform init
terraform apply
```

3 - Edit `/etc/ssh/ssh_config` in order to proxy jump from bastion servers to the nodes within private network
````
Host 10.0.*
    Port 22
    ProxyJump ubuntu@<bastion_task1_public_dns_domain>
    IdentityFile ~/.ssh/id_rsa
Host 20.0.*
    Port 22
    ProxyJump ubuntu@<bastion_task2_public_dns_domain>
    IdentityFile ~/.ssh/id_rsa
````

The bastion servers are secured regarding the security group rule that only allows the ingress of requests to 22 port from my public ip

4 - provision and configuring nginx web servers.

Nginx web servers have high availability regarding the redundancy of nodes (1 web servers/per az)

The nginx module contains:
* autoscaling group
* security group
* application load balancer

```
cd /mbio/terraform-modules/nginx
terraform init
terraform apply
```

Install in your local machine the ansible packages ansible_core and ansible_base

```
pip3 install ansible_base ansible_core
```

Run ansible playbook to configure nginx servers.

```
cd /mbio/ansible
ansible-playbook playbooks/nginx.yaml -i nginx_aws_ec2.yml --limit module_nginx -v
```

test the connectivity from bastion in vpc task1
```
ssh ubuntu@<bastion_task1_public_dns_domain>
ubuntu@ip-10-0-14-91:~$ curl internal-nginx-lb-1913643925.eu-central-1.elb.amazonaws.com
<!DOCTYPE html>
<html>
    <head>
        <title>Hello world</title>
    </head>
    <body>
        <p>Hello world.</p>
    </body>
</html>
```

5 - Provision infrastructure for task 3

The task3 module contains:
* ec2 instance to run docker container 
* security group for rds and ec2 instance
* rds instance with 1 day snapshot retention period.

```
cd /mbio/terraform-modules/task3
terraform init
terraform apply
```
<b>Note: Is required to provide a db password for admin </b>

Run ansible playbook to configure ec2 instance that runs docker container.
The playbook will:
* install docker dependencies
* install docker 
* pull jmendes18/mbio-task3:1.0 (located in `/mbio/docker`)
* run docker container
* install mysql to test connectivity with rds

```
cd /mbio/ansible
ansible-playbook playbooks/task3.yaml -i task3_aws_ec2.yml --limit module_task3 -v
```

test connectivity between ec2 instance in task3 with rds db
```
ubuntu@ip-20-0-11-190:~$ mysql -h task3-db.ccjtpuppnyvy.eu-central-1.rds.amazonaws.com -u admin -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 7
Server version: 5.7.33-log Source distribution

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

## How to destroy the cluster
To destroy all infrastructure is required to destroy the modules in the following order.
* tesk3
* nginx
* base
* account-config

## additional considerations.
This solution was orchestrated for aws free tier account, therefore this solution is not 
the optimal solution for a production environment.
For example in normal conditions I would go for eks cluster as an orchestrator or kops however eks is not covered in free tier account and kops create a nat gateway that is also payed resource.

Other example is storing secrets for database in normal cases I would use vault server or aws secret manager.

To create the domain I would use route53 to instead of using the elb domain.


In conclusion, I think this solution fits the requirements of this task however with a aws account without limitation the architecture would be different.
