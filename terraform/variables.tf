variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
  default     = null
  nullable    = true
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Use lowercase letters, numbers and hyphens only."
  }
}

variable "project_name" {
  description = "Project name."
  type        = string
  default     = "ha-three-tier"
}

variable "vnet_cidr" {
  description = "Virtual Network CIDR."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrsubnet(var.vnet_cidr, 8, 31)) && can(regex("^.+/([0-9]|1[0-9]|20)$", var.vnet_cidr))
    error_message = "vnet_cidr must be a valid IPv4 CIDR with a prefix of /20 or larger network, for example 10.0.0.0/16."
  }
}

variable "admin_username" {
  description = "Local administrator username for Linux VMs."
  type        = string
  default     = "azureadmin"
}

variable "ssh_public_key" {
  description = "SSH public key for VM administration through private access paths such as Bastion."
  type        = string
}

variable "web_vm_size" {
  description = "Web VM Scale Set instance size."
  type        = string
  default     = "Standard_B1s"
}

variable "app_vm_size" {
  description = "Application VM Scale Set instance size."
  type        = string
  default     = "Standard_B1s"
}

variable "web_instance_count" {
  description = "Number of web VM Scale Set instances."
  type        = number
  default     = 2
}

variable "app_instance_count" {
  description = "Number of application VM Scale Set instances."
  type        = number
  default     = 2
}

variable "app_port" {
  description = "Application tier HTTP port."
  type        = number
  default     = 3000
}

variable "db_name" {
  description = "Initial PostgreSQL database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "PostgreSQL administrator username."
  type        = string
  default     = "appadmin"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,62}$", var.db_username))
    error_message = "Username must start with a letter and contain only letters, numbers and underscores."
  }
}

variable "postgres_sku_name" {
  description = "Azure Database for PostgreSQL Flexible Server SKU."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgres_storage_mb" {
  description = "PostgreSQL storage size in MB."
  type        = number
  default     = 32768
}

variable "postgres_backup_retention_days" {
  description = "PostgreSQL backup retention in days."
  type        = number
  default     = 7
}

variable "application_gateway_certificate_name" {
  description = "Optional Application Gateway SSL certificate name."
  type        = string
  default     = null
  nullable    = true
}

variable "application_gateway_certificate_path" {
  description = "Optional path to a PFX certificate for HTTPS on Application Gateway."
  type        = string
  default     = null
  nullable    = true
}

variable "application_gateway_certificate_password" {
  description = "Optional PFX certificate password."
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}
