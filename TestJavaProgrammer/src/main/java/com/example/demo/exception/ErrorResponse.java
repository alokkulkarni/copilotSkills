package com.example.demo.exception;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.Instant;
import java.util.List;

/**
 * Standard error response structure for API errors.
 *
 * @param timestamp the time when the error occurred
 * @param status    the HTTP status code
 * @param error     the HTTP status reason phrase
 * @param message   a human-readable error message
 * @param path      the request path that caused the error
 * @param errors    a list of detailed validation errors (if applicable)
 */
@Schema(description = "Standard error response structure")
public record ErrorResponse(
        @Schema(description = "Time when the error occurred", example = "2026-02-01T10:30:00Z")
        Instant timestamp,
        
        @Schema(description = "HTTP status code", example = "400")
        int status,
        
        @Schema(description = "HTTP status reason phrase", example = "Bad Request")
        String error,
        
        @Schema(description = "Human-readable error message", example = "Validation failed")
        String message,
        
        @Schema(description = "Request path that caused the error", example = "/api/customers")
        String path,
        
        @Schema(description = "List of field-level validation errors (if applicable)", nullable = true)
        List<FieldError> errors
) {

    /**
     * Represents a field-level validation error.
     *
     * @param field   the field name that failed validation
     * @param message the validation error message
     */
    @Schema(description = "Field-level validation error details")
    public record FieldError(
            @Schema(description = "Name of the field that failed validation", example = "email")
            String field,
            
            @Schema(description = "Validation error message", example = "Email must be valid")
            String message
    ) {
    }
}
