variable "authorizers" {
  type = map(
    object({
      lambda                = object({ name = string, arn = string, invoke_arn = string })
      identity_validation   = optional(string, "^Bearer: .+$")
      result_ttl_in_seconds = optional(number, 300)
    })
  )
  default     = {}
  description = "Map of authorizer names to configuration objects"
}

variable "cache_size" {
  type        = string
  default     = "0"
  description = "Size of the cache in GB. Allowed values include `0`, `0.5`, `1.6`, `6.1`, `13.5`, `28.4`, `58.2`, `118`, and `237`."

  validation {
    condition     = contains(["0", "0.5", "1.6", "6.1", "13.5", "28.4", "58.2", "118", "237"], var.cache_size)
    error_message = "Cache size must be one of 0, 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118, or 237"
  }
}

variable "endpoints" {
  type = map(
    object({
      lambda                          = object({ name = string, invoke_arn = string })
      authorizer_name                 = optional(string)
      cache_ttl_in_seconds            = optional(number, 5)
      cache_data_encrypted            = optional(bool, true)
      cache_enabled                   = optional(bool, false)
      cache_control_authorized        = optional(bool, true)
      cache_control_response_strategy = optional(string, "SUCCEED_WITH_RESPONSE_HEADER")
      data_trace_enabled              = optional(bool, true)
      description                     = optional(string)
      metrics_enabled                 = optional(bool, true)
      logging_level                   = optional(string, "ERROR")
      payload_format_version          = optional(string, "2.0")
      timeout_milliseconds            = optional(number, 29000)
      throttling_burst_limit          = optional(number, -1)
      throttling_rate_limit           = optional(number, -1)
      validation                      = optional(string)
    })
  )
  description = "Map of routes to configuration objects"
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "KMS key used to encrypt APIGateway access logs"
}

variable "log_retention_in_days" {
  type        = number
  default     = 60
  description = "The number of days to retain APIGateway access logs in CloudWatch"
}

variable "service" {
  type        = string
  description = "Name of the service"
}