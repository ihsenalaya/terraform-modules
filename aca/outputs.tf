output "aca_env_id" {
  value = azurerm_container_app_environment.cae.id
}

output "job_name" {
  value = azurerm_container_app_job.job.name
}

output "job_resource_id" {
  value = azurerm_container_app_job.job.id
}