# Terraform

Terraform is used to implement the Azure three-tier architecture documented in the root-level architecture and security documents.

## Resources

The implementation covers:

- Resource group
- Virtual Network
- Public ingress, web, application and delegated database subnets
- NAT Gateway
- Route and subnet security controls through Network Security Groups
- Public Application Gateway
- Internal Azure Load Balancer
- Web Virtual Machine Scale Set
- Application Virtual Machine Scale Set
- Azure Database for PostgreSQL Flexible Server with zone-redundant HA
- Azure Key Vault
- User-assigned managed identity

## Configuration

Infrastructure settings are exposed through Terraform variables, including:

- Azure location
- Environment
- VM sizes and capacity
- PostgreSQL SKU and storage
- Network CIDRs
- Application port
- Optional TLS certificate settings

## Usage

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

## Notes

- The default configuration is intentionally small for learning and development. 
- Confirm that the selected Azure region supports Availability Zones and zone-redundant PostgreSQL Flexible Server before production deployment.
