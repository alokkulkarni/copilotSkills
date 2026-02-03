package com.example.demo.validation;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Validation annotation for UUID format.
 * Validates that a string matches the standard UUID format.
 */
@Target({ElementType.FIELD, ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = UUIDValidator.class)
@Documented
public @interface ValidUUID {

    /**
     * Error message to display when validation fails.
     *
     * @return the error message
     */
    String message() default "ID must be a valid UUID format";

    /**
     * Validation groups.
     *
     * @return the validation groups
     */
    Class<?>[] groups() default {};

    /**
     * Additional payload.
     *
     * @return the payload
     */
    Class<? extends Payload>[] payload() default {};
}
