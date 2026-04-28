provider "azurerm" {
  features {}
}

# --- GDPR DPIA Toolkit Foundation ---

resource "azurerm_resource_group" "privacy" {
  name     = "rg-${var.project_name}-foundation-${var.environment}"
  location = var.location
}

# --- Privacy Governance Network ---

resource "azurerm_virtual_network" "privacy" {
  name                = "vnet-${var.project_name}-governance-${var.environment}"
  location            = azurerm_resource_group.privacy.location
  resource_group_name = azurerm_resource_group.privacy.name
  address_space       = ["10.150.0.0/16"]

  tags = {
    Environment = var.environment
    CostCenter  = "Privacy-Compliance"
  }
}

# --- Assessment Metadata Store (Postgres) ---

resource "azurerm_postgresql_flexible_server" "privacy" {
  name                   = "psql-${var.project_name}-assessments-${var.environment}"
  resource_group_name    = azurerm_resource_group.privacy.name
  location               = azurerm_resource_group.privacy.location
  version                = "13"
  administrator_login    = "privacyadmin"
  administrator_password = var.db_password
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2ds_v4"
}

# --- Evidence Vault (Encrypted Storage) ---

resource "azurerm_storage_account" "evidence" {
  name                     = "st${var.project_name}evidence${var.environment}"
  resource_group_name      = azurerm_resource_group.privacy.name
  location                 = azurerm_resource_group.privacy.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  enable_https_traffic_only = true
  min_tls_version          = "TLS1_2"

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
  }
}

# --- Privacy Analytics Redis ---

resource "azurerm_redis_cache" "privacy" {
  name                = "redis-${var.project_name}-cache-${var.environment}"
  location            = azurerm_resource_group.privacy.location
  resource_group_name = azurerm_resource_group.privacy.name
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
}
