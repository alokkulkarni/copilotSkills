package com.example.demo.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.Arrays;
import java.util.List;

/**
 * CORS Configuration for allowing cross-origin requests from frontend applications.
 * Configures CORS settings to enable communication between the React frontend and Spring Boot backend.
 */
@Configuration
public class CorsConfig {

    /**
     * Configures CORS settings to allow requests from the React frontend.
     * 
     * @return CorsFilter with configured CORS settings
     */
    @Bean
    public CorsFilter corsFilter() {
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        CorsConfiguration config = new CorsConfiguration();
        
        // Allow credentials (cookies, authorization headers)
        config.setAllowCredentials(true);
        
        // Allow requests from React development server and production origins
        config.setAllowedOrigins(Arrays.asList(
            "http://localhost:3000",    // React dev server (Vite default)
            "http://localhost:5173",    // Alternative Vite port
            "http://localhost:4173",    // Vite preview port
            "http://127.0.0.1:3000",
            "http://127.0.0.1:5173"
        ));
        
        // Allow all headers
        config.setAllowedHeaders(List.of("*"));
        
        // Allow common HTTP methods
        config.setAllowedMethods(Arrays.asList(
            "GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH", "HEAD"
        ));
        
        // Expose common headers
        config.setExposedHeaders(Arrays.asList(
            "Authorization",
            "Content-Type",
            "X-Total-Count",
            "X-Page-Number",
            "X-Page-Size"
        ));
        
        // Cache preflight requests for 1 hour
        config.setMaxAge(3600L);
        
        // Apply CORS configuration to all endpoints
        source.registerCorsConfiguration("/**", config);
        
        return new CorsFilter(source);
    }
}
