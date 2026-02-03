package com.example.demo.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

import java.util.regex.Pattern;

/**
 * Validator implementation for ValidUUID annotation.
 * Validates that a string matches the standard UUID format.
 */
public class UUIDValidator implements ConstraintValidator<ValidUUID, String> {

    private static final Pattern UUID_PATTERN = Pattern.compile(
            "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$",
            Pattern.CASE_INSENSITIVE
    );

    @Override
    public void initialize(ValidUUID constraintAnnotation) {
        // No initialization needed
    }

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        // Null values are considered valid (use @NotNull for null check)
        if (value == null || value.isBlank()) {
            return true;
        }
        return UUID_PATTERN.matcher(value).matches();
    }
}
