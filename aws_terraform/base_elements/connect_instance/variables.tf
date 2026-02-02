# ============================================
# AWS Connect Instance Core Configuration
# ============================================

variable "instance_alias" {
  description = "The alias for the Connect instance. Must be unique across AWS account"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.instance_alias))
    error_message = "Instance alias must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "identity_management_type" {
  description = "Type of identity management for the Connect instance"
  type        = string
  default     = "CONNECT_MANAGED"

  validation {
    condition     = contains(["CONNECT_MANAGED", "SAML", "EXISTING_DIRECTORY"], var.identity_management_type)
    error_message = "Identity management type must be one of: CONNECT_MANAGED, SAML, EXISTING_DIRECTORY."
  }
}

variable "inbound_calls_enabled" {
  description = "Enable inbound calling for the Connect instance"
  type        = bool
  default     = true
}

variable "outbound_calls_enabled" {
  description = "Enable outbound calling for the Connect instance"
  type        = bool
  default     = true
}

variable "contact_flow_logs_enabled" {
  description = "Enable contact flow logs in CloudWatch"
  type        = bool
  default     = true
}

variable "contact_lens_enabled" {
  description = "Enable Contact Lens for Amazon Connect (analytics and insights)"
  type        = bool
  default     = false
}

variable "auto_resolve_best_voices_enabled" {
  description = "Enable auto resolve best voices for text-to-speech"
  type        = bool
  default     = true
}

variable "early_media_enabled" {
  description = "Enable early media (allows audio before call is answered)"
  type        = bool
  default     = true
}

variable "multi_party_conference_enabled" {
  description = "Enable multi-party conference capability"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days for contact flow logs"
  type        = number
  default     = 7

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention must be a valid CloudWatch retention period (1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, or 3653 days)."
  }
}

# ============================================
# Directory/SAML Configuration (Optional)
# ============================================

variable "directory_id" {
  description = "The identifier for the directory if using EXISTING_DIRECTORY"
  type        = string
  default     = null
}

variable "instance_role_arn" {
  description = "ARN of the IAM role for the Connect instance (for SAML)"
  type        = string
  default     = null
}

variable "connect_iam_policy_arn" {
  description = "IAM policy ARN to attach to Connect instance role. Set to empty string to skip attaching managed policy."
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonConnect_FullAccess"
}

# ============================================
# Hours of Operation Configuration
# ============================================

variable "hours_of_operation" {
  description = "List of hours of operation configurations"
  type = list(object({
    name        = string
    description = string
    time_zone   = string
    config = list(object({
      day = string # MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY
      start_time = object({
        hours   = number
        minutes = number
      })
      end_time = object({
        hours   = number
        minutes = number
      })
    }))
  }))
  default = []
}

# ============================================
# Queue Configuration
# ============================================

variable "queues" {
  description = "List of queue configurations"
  type = list(object({
    name                          = string
    description                   = string
    hours_of_operation_name       = string # Reference to hours_of_operation name
    max_contacts                  = optional(number)
    outbound_caller_id_name       = optional(string)
    outbound_caller_id_number_key = optional(string) # Reference to phone_numbers key
    status                        = optional(string, "ENABLED") # ENABLED or DISABLED
    quick_connect_keys            = optional(list(string), [])  # References to quick_connects keys
  }))
  default = []
}

# ============================================
# Routing Profile Configuration
# ============================================

variable "routing_profiles" {
  description = "List of routing profile configurations"
  type = list(object({
    name                          = string
    description                   = string
    default_outbound_queue_name   = string # Reference to queue name
    media_concurrencies = list(object({
      channel     = string # VOICE, CHAT, TASK
      concurrency = number
    }))
    queue_configs = optional(list(object({
      channel  = string # VOICE, CHAT, TASK
      delay    = number
      priority = number
      queue_name = string # Reference to queue name
    })), [])
  }))
  default = []
}

# ============================================
# Security Profile Configuration
# ============================================

variable "security_profiles" {
  description = "List of security profile configurations"
  type = list(object({
    name        = string
    description = string
    permissions = list(string) # List of Connect permissions
  }))
  default = []
}

# ============================================
# User Configuration
# ============================================

variable "users" {
  description = "List of user configurations"
  type = list(object({
    username                 = string
    password                 = optional(string) # Only for CONNECT_MANAGED, marked sensitive
    email                    = optional(string)
    first_name              = string
    last_name               = string
    phone_type              = optional(string, "SOFT_PHONE") # SOFT_PHONE, DESK_PHONE
    phone_number            = optional(string) # Required if phone_type is DESK_PHONE
    auto_accept             = optional(bool, false)
    after_contact_work_time = optional(number, 0)
    desk_phone_number       = optional(string)
    routing_profile_name    = string # Reference to routing profile name
    security_profile_names  = list(string) # References to security profile names
    hierarchy_group_name    = optional(string)
  }))
  default = []

  sensitive = true # Users may contain passwords
}

# ============================================
# Admin User Configuration
# ============================================

variable "create_admin_user" {
  description = "Create an admin user for the Connect instance"
  type        = bool
  default     = false
}

variable "admin_user" {
  description = "Admin user configuration"
  type = object({
    username   = string
    password   = optional(string) # Only for CONNECT_MANAGED
    email      = string
    first_name = string
    last_name  = string
  })
  default = {
    username   = "admin"
    email      = "admin@example.com"
    first_name = "Admin"
    last_name  = "User"
  }

  sensitive = true # May contain password
}

# ============================================
# Phone Number Configuration
# ============================================

variable "phone_numbers" {
  description = "Map of phone numbers to provision"
  type = map(object({
    country_code = string # ISO country code (e.g., GB, US)
    type         = string # DID or TOLL_FREE
    description  = optional(string)
  }))
  default = {}
}

# ============================================
# Quick Connect Configuration
# ============================================

variable "quick_connects" {
  description = "Map of quick connect configurations"
  type = map(object({
    name        = string
    description = string
    type        = string # PHONE_NUMBER, QUEUE, USER
    phone_number = optional(string) # For PHONE_NUMBER type
    queue_name   = optional(string) # For QUEUE type (reference to queue name)
    user_name    = optional(string) # For USER type (reference to user username)
  }))
  default = {}
}

# ============================================
# Contact Flow Configuration
# ============================================

variable "contact_flows" {
  description = "List of contact flow configurations"
  type = list(object({
    name        = string
    description = string
    type        = optional(string, "CONTACT_FLOW") # CONTACT_FLOW, CUSTOMER_QUEUE, CUSTOMER_HOLD, etc.
    content     = optional(string) # JSON content of the flow
    filename    = optional(string) # Path to JSON file containing flow content
  }))
  default = []
}

# ============================================
# Lambda Function Association
# ============================================

variable "lambda_functions" {
  description = "Map of Lambda functions to associate with Connect instance"
  type = map(object({
    function_arn = string
  }))
  default = {}
}

# ============================================
# Lex Bot Association
# ============================================

variable "lex_bots" {
  description = "List of Lex bots to associate with Connect instance"
  type = list(object({
    name       = string
    lex_region = optional(string) # Region where Lex bot is deployed, defaults to current region
    alias_arn  = optional(string) # Lex V2 bot alias ARN
  }))
  default = []
}

# ============================================
# Tags
# ============================================

variable "tags" {
  description = "Tags to apply to all Connect resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
  }
}

variable "instance_tags" {
  description = "Additional tags specific to the Connect instance"
  type        = map(string)
  default     = {}
}
