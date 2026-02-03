package com.example.demo.config;

import jakarta.validation.constraints.NotBlank;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

/**
 * Configuration properties for data storage settings.
 * Provides type-safe access to data storage configuration.
 */
@ConfigurationProperties(prefix = "app.data")
@Validated
public class DataStorageProperties {

    /**
     * Path to the JSON file for storing customer data.
     * Defaults to "customers.json" in the application directory.
     */
    @NotBlank(message = "Data file path cannot be blank")
    private String file = "customers.json";

    /**
     * Gets the data file path.
     *
     * @return the path to the data file
     */
    public String getFile() {
        return file;
    }

    /**
     * Sets the data file path.
     *
     * @param file the path to the data file
     */
    public void setFile(String file) {
        this.file = file;
    }
}
