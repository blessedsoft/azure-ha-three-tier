# Security Design

## Security Model

The architecture uses separate Network Security Groups for each tier and permits only required tier-to-tier communication.

## Tier-to-Tier Ports

| Source | Destination | Port | Purpose |
| :--- | :--- | :--- | :--- |
| Internet | Application Gateway | `80` / `443` | Web access |
| Application Gateway subnet | Web subnet | `80` | Gateway to Nginx |
| Web subnet | Internal Load Balancer | `3000` | Web to application |
| Internal Load Balancer | App subnet | `3000` | Load balancer to Node.js |
| App subnet | PostgreSQL delegated subnet | `5432` | PostgreSQL |
| Web/App subnets | Internet via NAT Gateway | `443` | Outbound HTTPS |
| Web/App subnets | Azure platform DNS | `53` | Name resolution |

## Least Privilege

- Application Gateway accepts only required HTTP/HTTPS traffic.
- Web VMs accept HTTP only from the Application Gateway subnet.
- Application VMs accept application traffic only from the web/application load-balancing path.
- PostgreSQL accepts connections only from the application subnet.
- No direct Internet access is assigned to web or application VMs.
- SSH port `22` is not publicly exposed.

## Secrets Management

Database credentials must not be hardcoded in application code.

Terraform generates the PostgreSQL administrator password and stores it in Azure Key Vault:

```hcl
resource "azurerm_key_vault_secret" "postgres_admin_password" {
  name         = "postgres-admin-password"
  value        = random_password.postgres_admin.result
  key_vault_id = azurerm_key_vault.main.id
}
```

Application workloads use a user-assigned managed identity with minimum required Key Vault permissions.

Sensitive files such as Terraform state, private keys, `.tfvars`, and credentials must not be committed to Git.

## Encryption

### At Rest

- Azure managed disks are encrypted by default.
- PostgreSQL storage encryption is enabled by the platform.
- Key Vault protects secrets with Azure platform encryption.
- Customer-managed keys can be introduced where required by policy.

### In Transit

- HTTPS can be enabled on Application Gateway with an existing certificate.
- PostgreSQL requires TLS by default.
- Internal TLS can be introduced where required by the security policy.

## Administration

VM administration should use Azure Bastion, Just-in-Time VM Access, or Azure Arc/Run Command patterns instead of public SSH.

## Production Hardening

Future improvements may include:

- Azure Web Application Firewall on Application Gateway
- Azure Monitor alerts and dashboards
- Log Analytics centralized logging
- Private DNS zone hardening
- Azure Policy guardrails
- Defender for Cloud recommendations
- Terraform remote state in Azure Storage with state locking
- Backup and restore testing
- Vulnerability management and image patch automation
