package com.example.demo.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * Configuration class for OpenAPI/Swagger documentation.
 * Customizes the API documentation with metadata, contact info, and server URLs.
 */
@Configuration
public class OpenApiConfig {

    @Value("${server.port:8080}")
    private int serverPort;

    /**
     * Creates and configures the OpenAPI specification bean.
     *
     * @return configured OpenAPI instance
     */
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Customer Management API")
                        .version("1.0.0")
                        .description("""
                                REST API for managing customer data. Provides complete CRUD operations
                                for customers with validation, pagination support, and consistent error handling.
                                
                                ## Features
                                - **CRUD Operations**: Create, Read, Update, and Delete customers
                                - **Pagination**: Paginated list endpoints with metadata
                                - **Validation**: Input validation with detailed error messages
                                - **Error Handling**: Consistent error response format
                                
                                ## Data Storage
                                Customer data is persisted to a local JSON file for simplicity.
                                """)
                        .contact(new Contact()
                                .name("API Support")
                                .email("support@example.com"))
                        .license(new License()
                                .name("MIT License")
                                .url("https://opensource.org/licenses/MIT")))
                .servers(List.of(
                        new Server()
                                .url("http://localhost:" + serverPort)
                                .description("Local Development Server"),
                        new Server()
                                .url("https://api.example.com")
                                .description("Production Server")
                ));
    }
}
