## Automating VPC creation using Terraform resource and terraform module

- VPC

- two availability zones

- two public subnets

- 4 private subnets - (RDS private Subnet, and EC2 Private Subnets)

- 2 Security groups - (EC2 Security group and RDS Security group)

- Two route tables (Private rt and public rt)

- Nat gateway

- Internet Gateway

## Count
The count parameter tells Terraform to create multiple instances of the aws_subnet resource, one for each CIDR block defined in the **public_subnet_cidrs** variable
The **length(var.public_subnet_cidrs)** expression calculates the number of elements in public_subnet_cidrs, so if there are three CIDR blocks, three subnets will be created

## element

cidr_block = **element(var.public_subnet_cidrs, count.index)**

This line assigns a CIDR block to each subnet. The **element(var.public_subnet_cidrs, count.index)** function retrieves a specific CIDR block from the **public_subnet_cidrs** list based on the current index (count.index). So, for each iteration, it assigns a different CIDR block from public_subnet_cidrs to each subnet.

The tags block assigns tags to the subnet. The Name tag is set to "Public Subnet <index>, where <index> is count.index + 1 (to make it more human-readable, starting from 1 instead of 0). Tags help with identifying and managing resources in AWS.

## Command

- terraform init - Initialise terraform

- terraform plan - overview of resource to create and configuration validation

- terraform apply --auto-approve - apply the terraform config without manual approval

- terraform destroy --auto-approve - Destroy terraform without manual approval