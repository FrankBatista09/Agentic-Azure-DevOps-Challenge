variable "location" {
  type        = string
  description = "Azure region for deployment"
  default     = "eastus"
}

variable "app_name" {
  type        = string
  description = "Application name"
  default     = "rdicidr"
}

variable "acr_id" {
  type        = string
  description = "Resource ID of the Azure Container Registry"
  default     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-acr/providers/Microsoft.ContainerRegistry/registries/rdicidr"
}

variable "acr_login_server" {
  type        = string
  description = "ACR login server hostname"
  default     = "rdicidr.azurecr.io"
}

variable "container_image" {
  type        = string
  description = "Container image URI"
  default     = "rdicidr.azurecr.io/rdicidr:latest"
}

variable "container_port" {
  type        = number
  description = "Port the container listens on"
  default     = 80
}

variable "health_check_path" {
  type        = string
  description = "Health check endpoint path"
  default     = "/healthz"
}

variable "min_replicas" {
  type        = number
  description = "Minimum number of container replicas"
  default     = 2
}

variable "max_replicas" {
  type        = number
  description = "Maximum number of container replicas"
  default     = 2
}
