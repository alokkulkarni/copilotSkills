package com.example.demo.controller;

import com.example.demo.exception.ErrorResponse;
import com.example.demo.model.Customer;
import com.example.demo.model.PageResponse;
import com.example.demo.service.CustomerServiceInterface;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * REST Controller for managing Customer resources.
 * Provides endpoints for CRUD operations on customers.
 */
@RestController
@RequestMapping("/api/v1/customers")
@Tag(name = "Customers", description = "Customer management operations")
@Validated
public class CustomerController {

    private final CustomerServiceInterface service;

    /**
     * Constructs a CustomerController with the required service.
     *
     * @param service the customer service for business logic
     */
    public CustomerController(CustomerServiceInterface service) {
        this.service = service;
    }

    /**
     * Retrieves a paginated list of all customers.
     *
     * @param page the page number (zero-based), defaults to 0
     * @param size the number of records per page, defaults to 20
     * @return a PageResponse containing customers and pagination metadata
     */
    @Operation(
            summary = "List all customers",
            description = "Retrieves a paginated list of all customers. Supports pagination through page and size query parameters."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved paginated list of customers"),
            @ApiResponse(responseCode = "500", description = "Internal server error",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping
    public PageResponse<Customer> getAllCustomers(
            @Parameter(description = "Page number (zero-based)", example = "0")
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @Parameter(description = "Number of records per page (max 100)", example = "20")
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return service.getAllCustomersPaged(page, size);
    }

    /**
     * Retrieves a customer by their unique identifier.
     *
     * @param id the unique identifier of the customer
     * @return ResponseEntity with the customer if found, or 404 Not Found
     */
    @Operation(
            summary = "Get a customer by ID",
            description = "Retrieves a specific customer by their unique identifier."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Customer found"),
            @ApiResponse(responseCode = "404", description = "Customer not found", content = @Content),
            @ApiResponse(responseCode = "500", description = "Internal server error",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/{id}")
    public ResponseEntity<Customer> getCustomer(
            @Parameter(description = "Unique identifier of the customer", example = "123e4567-e89b-12d3-a456-426614174000")
            @PathVariable String id) {
        return service.getCustomer(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Creates a new customer.
     *
     * @param customer the customer data to create (validated)
     * @return ResponseEntity with the created customer and 201 Created status
     */
    @Operation(
            summary = "Create a new customer",
            description = "Creates a new customer with the provided data. A unique ID will be generated automatically if not provided."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Customer created successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "500", description = "Internal server error",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping
    public ResponseEntity<Customer> addCustomer(@Valid @RequestBody Customer customer) {
        Customer created = service.addCustomer(customer);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    /**
     * Updates an existing customer.
     *
     * @param id       the unique identifier of the customer to update
     * @param customer the updated customer data (validated)
     * @return ResponseEntity with the updated customer if found, or 404 Not Found
     */
    @Operation(
            summary = "Update a customer",
            description = "Updates an existing customer with the provided data. The customer ID in the path takes precedence."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Customer updated successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "404", description = "Customer not found", content = @Content),
            @ApiResponse(responseCode = "500", description = "Internal server error",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/{id}")
    public ResponseEntity<Customer> updateCustomer(
            @Parameter(description = "Unique identifier of the customer", example = "123e4567-e89b-12d3-a456-426614174000")
            @PathVariable String id,
            @Valid @RequestBody Customer customer) {
        return service.updateCustomer(id, customer)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Deletes a customer by their unique identifier.
     *
     * @param id the unique identifier of the customer to delete
     * @return ResponseEntity with 204 No Content if deleted, or 404 Not Found
     */
    @Operation(
            summary = "Delete a customer",
            description = "Deletes a customer by their unique identifier."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "204", description = "Customer deleted successfully"),
            @ApiResponse(responseCode = "404", description = "Customer not found", content = @Content),
            @ApiResponse(responseCode = "500", description = "Internal server error",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCustomer(
            @Parameter(description = "Unique identifier of the customer", example = "123e4567-e89b-12d3-a456-426614174000")
            @PathVariable String id) {
        if (service.deleteCustomer(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
