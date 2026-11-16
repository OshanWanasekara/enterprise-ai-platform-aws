
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = "rg-enterprise-ai-platform"
}

variable "location" {
  description = "Azure resource group location"
  type        = string
  default     = "southeastasia"
}

