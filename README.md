# Terraform-VPC-Infrastructure

## List of steps to perform:

1. Create a Provider for AWS.
2. Create a VPC (Virtual Private Cloud in AWS).
3. Create a Public Subnet with auto public IP Assignment enabled in custom VPC.
4. Create a Private Subnet in custom VPC.
5. Create an Internet Gateway for Instances in the public subnet to access the Internet.
6. Create a routing table consisting of the information of Internet Gateway.
7. Associate the routing table to the Public Subnet to provide the Internet Gateway address.
8. Creating an Elastic IP for the NAT Gateway.
9. Creating a NAT Gateway for instances in the private subnet to access the Internet (performing source NAT).
10. Creating a route table for the Nat Gateway Access which has to be associated with the Instances in the Priavte subnet.
11. Associate the routing table to the Private Subnet to provide the Nat Gateway address.

![](https://visitor-badge.glitch.me/badge?page_id=24-komal.Terraform-VPC-Infrastructure)
