# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"

  backend "azurerm" {
      resource_group_name  = "rg-tfstate"
      storage_account_name = "tfstate1078925435"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg1" {
  name     = var.resource_group_name
  location = "eastus"
}

# Create CoreServicesVnet Virtual Network
resource "azurerm_virtual_network" "vnet1" {
  name                = "CoreServicesVnet"
  address_space       = ["10.20.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg1.name

  subnet {
    name           = "GatewaySubnet"
    address_prefix = "10.20.0.0/27"
  }

  subnet {
    name           = "SharedServicesSubnet"
    address_prefix = "10.20.10.0/24"
  }

  subnet {
    name           = "DatabaseSubnet"
    address_prefix = "10.20.20.0/24"
  }

  subnet {
    name           = "PublicWebServiceSubnet"
    address_prefix = "10.20.30.0/24"
  }
}

# Create ManufacturingVnet Virtual Network
resource "azurerm_virtual_network" "vnet2" {
  name                = "ManufacturingVnet"
  address_space       = ["10.30.0.0/16"]
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.rg1.name

  subnet {
    name           = "ManufacturingSystemSubnet"
    address_prefix = "10.30.10.0/24"
  }

  subnet {
    name           = "SensorSubnet1"
    address_prefix = "10.30.20.0/24"
  }

  subnet {
    name           = "SensorSubnet2"
    address_prefix = "10.30.21.0/24"
  }

  subnet {
    name           = "SensorSubnet3"
    address_prefix = "10.30.22.0/24"
  }
}

# Create ResearchVnet Virtual Network
resource "azurerm_virtual_network" "vnet3" {
  name                = "ResearchVnet"
  address_space       = ["10.40.0.0/16"]
  location            = "southeastasia"
  resource_group_name = azurerm_resource_group.rg1.name

  subnet {
    name           = "ResearchSystemSubnet"
    address_prefix = "10.40.0.0/24"
  }
}

# Create DNS resources
resource "azurerm_private_dns_zone" "dns1" {
  name                = "contoso.com"
  resource_group_name = azurerm_resource_group.rg1.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link1" {
  name                  = "CoreServicesVnetLink"
  resource_group_name   = azurerm_resource_group.rg1.name
  private_dns_zone_name = azurerm_private_dns_zone.dns1.name
  virtual_network_id    = azurerm_virtual_network.vnet1.id
  registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "link2" {
  name                  = "ManufacturingVnetLink"
  resource_group_name   = azurerm_resource_group.rg1.name
  private_dns_zone_name = azurerm_private_dns_zone.dns1.name
  virtual_network_id    = azurerm_virtual_network.vnet2.id
  registration_enabled = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "link3" {
  name                  = "ResearchSystemSubnetLink"
  resource_group_name   = azurerm_resource_group.rg1.name
  private_dns_zone_name = azurerm_private_dns_zone.dns1.name
  virtual_network_id    = azurerm_virtual_network.vnet3.id
  registration_enabled = true
}
