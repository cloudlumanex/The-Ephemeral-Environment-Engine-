output "namespace" {
  description = "Kubernetes namespace created for this environment"
  value       = kubernetes_namespace.preview.metadata[0].name
}

output "db_host" {
  description = "Database host (service name)"
  value       = "${kubernetes_service.postgres.metadata[0].name}.${kubernetes_namespace.preview.metadata[0].name}.svc.cluster.local"
}

output "db_port" {
  description = "Database port"
  value       = kubernetes_service.postgres.spec[0].port[0].port
}

output "db_name" {
  description = "Database name"
  value       = var.db_name
}

output "db_connection_string" {
  description = "PostgreSQL connection string for the application"
  value       = "postgresql://${var.db_user}:${var.db_password}@${kubernetes_service.postgres.metadata[0].name}.${kubernetes_namespace.preview.metadata[0].name}.svc.cluster.local:5432/${var.db_name}"
  sensitive   = true
}
