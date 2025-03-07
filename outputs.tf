output "automation_account_name" {
  description = "Name of the automation account"
  value       = azurerm_automation_account.this.name
}

output "hybrid_service_url" {
  description = "Hybrid worker group URL for the automation account"
  value       = azurerm_automation_account.this.hybrid_service_url
}

output "resource_id" {
  description = "ID of the automation account"
  value       = azurerm_automation_account.this.id
}
