variable "environment" {
  type        = string
  description = "Deployment environment (devel or stage)"

  validation {
    condition     = contains(["devel", "stage"], var.environment)
    error_message = "environment must be either \"devel\" or \"stage\"."
  }
}

variable "location" {
  type        = string
  description = "Azure region for deployment"
  default     = "eastus"
}

variable "app_name" {
  type        = string
  description = "Application name (lowercase letters and digits, used in globally unique names)"
  default     = "rdicidr"

  validation {
    condition     = can(regex("^[a-z0-9]{3,15}$", var.app_name))
    error_message = "app_name must be 3-15 lowercase letters or digits."
  }
}

variable "vnet_address_space" {
  type        = string
  description = "Address space (a /16 CIDR block) of the environment VNet"

  validation {
    condition     = can(cidrhost(var.vnet_address_space, 0)) && try(tonumber(split("/", var.vnet_address_space)[1]) == 16, false)
    error_message = "vnet_address_space must be a valid /16 CIDR block."
  }
}

variable "image_repository" {
  type        = string
  description = "Repository name of the image inside the ACR"
  default     = "rdicidr"
}

variable "image_tag" {
  type        = string
  description = "Image tag to deploy (the pipeline passes the commit SHA)"

  validation {
    condition     = length(trimspace(var.image_tag)) > 0
    error_message = "image_tag must not be empty."
  }
}

variable "container_port" {
  type        = number
  description = "Port the container listens on"
  default     = 80
}

variable "health_check_path" {
  type        = string
  description = "Health check endpoint path"
  default     = "/health"
}

variable "min_replicas" {
  type        = number
  description = "Minimum number of container replicas"
  default     = 1

  validation {
    condition     = var.min_replicas >= 1
    error_message = "min_replicas must be at least 1."
  }
}

variable "max_replicas" {
  type        = number
  description = "Maximum number of container replicas"
  default     = 2

  validation {
    condition     = var.max_replicas >= var.min_replicas
    error_message = "max_replicas must be greater than or equal to min_replicas."
  }
}

variable "log_retention_days" {
  type        = number
  description = "Log Analytics retention in days"
  default     = 30
}
