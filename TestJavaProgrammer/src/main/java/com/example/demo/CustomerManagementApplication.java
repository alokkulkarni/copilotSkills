package com.example.demo;

import com.example.demo.config.CorsProperties;
import com.example.demo.config.DataStorageProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

/**
 * Main application class for Customer Management API.
 * Enables configuration properties for type-safe configuration management.
 */
@SpringBootApplication
@EnableConfigurationProperties({DataStorageProperties.class, CorsProperties.class})
public class CustomerManagementApplication {

    public static void main(String[] args) {
        SpringApplication.run(CustomerManagementApplication.class, args);
    }

}
