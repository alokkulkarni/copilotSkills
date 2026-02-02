# ================================
# Bot Configuration Variables
# ================================

variable "bot_name" {
  description = "Name of the Lex bot"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.bot_name))
    error_message = "Bot name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "description" {
  description = "Description of the Lex bot"
  type        = string
  default     = ""
}

variable "idle_session_ttl_in_seconds" {
  description = "Time in seconds that a session can remain idle before it is closed"
  type        = number
  default     = 300

  validation {
    condition     = var.idle_session_ttl_in_seconds >= 60 && var.idle_session_ttl_in_seconds <= 86400
    error_message = "Idle session TTL must be between 60 and 86400 seconds."
  }
}

variable "child_directed" {
  description = "Whether the bot is subject to COPPA (Children's Online Privacy Protection Act)"
  type        = bool
  default     = false
}

variable "bot_members" {
  description = "List of bot members for network bots"
  type = list(object({
    alias_id   = string
    alias_name = string
    id         = string
    name       = string
    version    = string
  }))
  default = []
}

# ================================
# Locale Configuration
# ================================

variable "bot_locales" {
  description = "Map of locale configurations for the bot"
  type = map(object({
    description            = optional(string, "")
    nlu_confidence_threshold = optional(number, 0.4)
    voice_id              = optional(string, null)
    voice_engine          = optional(string, "standard")
  }))

  default = {
    "en_GB" = {
      description            = "English (GB)"
      nlu_confidence_threshold = 0.4
    }
  }

  validation {
    condition = alltrue([
      for locale, config in var.bot_locales :
      config.nlu_confidence_threshold >= 0 && config.nlu_confidence_threshold <= 1
    ])
    error_message = "NLU confidence threshold must be between 0 and 1."
  }
}

# ================================
# Intent Configuration
# ================================

variable "intents" {
  description = "Map of intents to create for the bot"
  type = map(object({
    locale_id                      = string
    description                    = optional(string, "")
    parent_intent_signature        = optional(string, null)
    sample_utterances              = list(string)
    slot_priorities                = optional(list(object({
      priority = number
      slot_id  = string
    })), [])
    enable_confirmation            = optional(bool, false)
    confirmation_prompt            = optional(string, null)
    confirmation_max_retries       = optional(number, 2)
    confirmation_allow_interrupt   = optional(bool, true)
    declination_response           = optional(string, null)
    closing_message                = optional(string, null)
    enable_dialog_code_hook        = optional(bool, false)
    enable_fulfillment_code_hook   = optional(bool, false)
    fulfillment_success_response   = optional(string, null)
    fulfillment_failure_response   = optional(string, null)
  }))

  default = {}
}

# ================================
# Slot Configuration
# ================================

variable "slots" {
  description = "Map of slots to create for intents"
  type = map(object({
    intent_name             = string
    locale_id               = string
    description             = optional(string, "")
    slot_type_id            = string
    is_required             = optional(bool, false)
    prompt_message          = optional(string, null)
    prompt_max_retries      = optional(number, 2)
    prompt_allow_interrupt  = optional(bool, true)
    default_values          = optional(list(string), [])
  }))

  default = {}
}

# ================================
# Custom Slot Type Configuration
# ================================

variable "custom_slot_types" {
  description = "Map of custom slot types to create"
  type = map(object({
    locale_id                   = string
    description                 = optional(string, "")
    resolution_strategy         = optional(string, "OriginalValue")
    enable_advanced_recognition = optional(bool, false)
    audio_recognition_strategy  = optional(string, null)
    values = list(object({
      value    = string
      synonyms = optional(list(string), [])
    }))
  }))

  default = {}

  validation {
    condition = alltrue([
      for slot_type, config in var.custom_slot_types :
      contains(["OriginalValue", "TopResolution"], config.resolution_strategy)
    ])
    error_message = "Resolution strategy must be either 'OriginalValue' or 'TopResolution'."
  }
}

# ================================
# Version Configuration
# ================================

variable "create_version" {
  description = "Whether to create a bot version"
  type        = bool
  default     = true
}

variable "version_description" {
  description = "Description for the bot version"
  type        = string
  default     = "Managed by Terraform"
}

# ================================
# Alias Configuration
# ================================

variable "bot_aliases" {
  description = "Map of bot aliases to create"
  type = map(object({
    description                 = optional(string, "")
    bot_version                 = optional(string, null)
    enable_conversation_logs    = optional(bool, false)
    text_log_group_arn          = optional(string, null)
    audio_log_s3_bucket         = optional(string, null)
    audio_log_prefix            = optional(string, "audio-logs/")
    enable_sentiment_analysis   = optional(bool, false)
    locale_settings = map(object({
      enabled    = optional(bool, true)
      lambda_arn = optional(string, null)
    }))
  }))

  default = {}
}

# ================================
# IAM Configuration
# ================================

variable "create_role" {
  description = "Whether to create IAM role for the bot"
  type        = bool
  default     = true
}

variable "role_arn" {
  description = "ARN of existing IAM role to use (if create_role is false)"
  type        = string
  default     = null
}

variable "attach_cloudwatch_policy" {
  description = "Whether to attach CloudWatch Logs policy to the IAM role"
  type        = bool
  default     = false
}

variable "attach_s3_policy" {
  description = "Whether to attach S3 policy for audio logs to the IAM role"
  type        = bool
  default     = false
}

variable "s3_bucket_arn" {
  description = "ARN of S3 bucket for audio logs (if attach_s3_policy is true)"
  type        = string
  default     = null
}

# ================================
# Tags
# ================================

variable "tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default     = {}
}
