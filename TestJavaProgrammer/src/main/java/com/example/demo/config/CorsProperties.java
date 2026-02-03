package com.example.demo.config;

import jakarta.validation.constraints.NotEmpty;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

import java.util.List;

/**
 * Configuration properties for CORS settings.
 * Provides type-safe access to CORS configuration.
 */
@ConfigurationProperties(prefix = "app.cors")
@Validated
public class CorsProperties {

    /**
     * List of allowed origins for CORS requests.
     * Defaults to common development ports.
     */
    @NotEmpty(message = "At least one allowed origin must be specified")
    private List<String> allowedOrigins = List.of(
            "http://localhost:3000",
            "http://localhost:5173",
            "http://localhost:4173",
            "http://127.0.0.1:3000",
            "http://127.0.0.1:5173"
    );

    /**
     * Gets the list of allowed origins.
     *
     * @return list of allowed origin URLs
     */
    public List<String> getAllowedOrigins() {
        return allowedOrigins;
    }

    /**
     * Sets the list of allowed origins.
     *
     * @param allowedOrigins list of allowed origin URLs
     */
    public void setAllowedOrigins(List<String> allowedOrigins) {
        this.allowedOrigins = allowedOrigins;
    }
}
