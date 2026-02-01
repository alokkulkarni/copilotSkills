package com.example.demo.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

/**
 * Represents a customer entity with validation constraints.
 * This is an immutable record containing customer information.
 *
 * @param id    the unique identifier of the customer (auto-generated if not provided)
 * @param name  the name of the customer (required, cannot be blank)
 * @param email the email address of the customer (required, must be valid email format)
 */
@Schema(description = "A customer entity")
public record Customer(
        @Schema(description = "Unique identifier for the customer (UUID format)", 
                example = "123e4567-e89b-12d3-a456-426614174000")
        String id,
        
        @Schema(description = "Full name of the customer", example = "John Doe", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotBlank(message = "Name is required")
        String name,
        
        @Schema(description = "Email address of the customer", example = "john.doe@example.com", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotBlank(message = "Email is required")
        @Email(message = "Email must be valid")
        String email
) {
}
