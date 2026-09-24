# Azure Architecture Diagram

```mermaid
flowchart TB
    users[Internet Users] --> pip[Public IP]
    pip --> appgw[Azure Application Gateway]

    subgraph region[Azure Region]
      subgraph vnet[Virtual Network 10.0.0.0/16]
        subgraph ingress[Ingress Subnet]
          appgw
          nat[NAT Gateway]
        end

        subgraph web[Web Subnet]
          web_a[Web VMSS Instance - Zone 1]
          web_b[Web VMSS Instance - Zone 2]
        end

        subgraph app[Application Subnet]
          ilb[Internal Load Balancer]
          app_a[App VMSS Instance - Zone 1]
          app_b[App VMSS Instance - Zone 2]
        end

        subgraph data[Database Subnet]
          postgres[(PostgreSQL Flexible Server - Zone Redundant HA)]
        end

        kv[Azure Key Vault]
      end
    end

    appgw --> web_a
    appgw --> web_b
    web_a --> ilb
    web_b --> ilb
    ilb --> app_a
    ilb --> app_b
    app_a --> postgres
    app_b --> postgres
    app_a --> kv
    app_b --> kv
    web_a --> nat
    web_b --> nat
    app_a --> nat
    app_b --> nat
```

## Tier Mapping

| AWS concept | Azure equivalent |
| :--- | :--- |
| VPC | Virtual Network |
| Public subnet | Application Gateway ingress subnet |
| Private web subnet | Web subnet with VM Scale Set |
| Private app subnet | Application subnet with VM Scale Set |
| DB subnet group | Delegated PostgreSQL subnet |
| Public Application Load Balancer | Azure Application Gateway |
| Internal Application Load Balancer | Internal Azure Load Balancer |
| EC2 Auto Scaling Group | Virtual Machine Scale Set |
| RDS PostgreSQL Multi-AZ | Azure Database for PostgreSQL Flexible Server with zone-redundant HA |
| Security group | Network Security Group |
| Secrets Manager | Azure Key Vault |
| IAM instance profile | User-assigned managed identity |

## Traffic Flow

1. Internet users reach the public Application Gateway.
2. Application Gateway then forwards HTTP traffic to the private web VM Scale Set.
3. Web instances proxy application traffic to the internal Load Balancer on port `3000`.
4. The internal Load Balancer sends traffic to the private application VM Scale Set.
5. Application instances connect to PostgreSQL on port `5432`.
6. Web and application instances use NAT Gateway for controlled outbound HTTPS.

## Availability

The web and application VM Scale Sets span multiple Availability Zones where the selected region supports them. PostgreSQL Flexible Server is configured with zone-redundant high availability.
