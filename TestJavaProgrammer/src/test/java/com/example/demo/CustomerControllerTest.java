package com.example.demo;

import com.example.demo.controller.CustomerController;
import com.example.demo.exception.GlobalExceptionHandler;
import com.example.demo.model.Customer;
import com.example.demo.model.PageResponse;
import com.example.demo.service.CustomerServiceInterface;
import com.example.demo.testutil.CustomerTestBuilder;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.List;
import java.util.Optional;
import java.util.stream.Stream;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Unit tests for CustomerController using standalone MockMvc setup.
 * Tests the controller in isolation with mocked service dependencies.
 * Uses MockitoExtension for pure unit testing without Spring context.
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("CustomerController Unit Tests")
class CustomerControllerTest {

    private MockMvc mockMvc;

    @Mock
    private CustomerServiceInterface service;

    @InjectMocks
    private CustomerController controller;

    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        objectMapper = new ObjectMapper();
        mockMvc = MockMvcBuilders.standaloneSetup(controller)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();
    }

    @Nested
    @DisplayName("GET /api/v1/customers - List Customers")
    class GetAllCustomersTests {

        @Test
        @DisplayName("Should return paginated customers with default pagination")
        void shouldReturnPagedCustomers() throws Exception {
            // Arrange
            List<Customer> customers = List.of(
                    CustomerTestBuilder.validCustomer(),
                    CustomerTestBuilder.secondCustomer()
            );
            PageResponse<Customer> pageResponse = new PageResponse<>(customers, 0, 20, 2, 1);
            when(service.getAllCustomersPaged(0, 20)).thenReturn(pageResponse);

            // Act & Assert
            mockMvc.perform(get("/api/v1/customers"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.content").isArray())
                    .andExpect(jsonPath("$.content.length()").value(2))
                    .andExpect(jsonPath("$.page").value(0))
                    .andExpect(jsonPath("$.size").value(20))
                    .andExpect(jsonPath("$.totalElements").value(2))
                    .andExpect(jsonPath("$.totalPages").value(1));

            verify(service).getAllCustomersPaged(0, 20);
        }

        @Test
        @DisplayName("Should return custom paginated results when page and size specified")
        void shouldReturnCustomPagedResults() throws Exception {
            // Arrange
            List<Customer> customers = List.of(CustomerTestBuilder.thirdCustomer());
            PageResponse<Customer> pageResponse = new PageResponse<>(customers, 1, 2, 5, 3);
            when(service.getAllCustomersPaged(1, 2)).thenReturn(pageResponse);

            // Act & Assert
            mockMvc.perform(get("/api/v1/customers")
                            .param("page", "1")
                            .param("size", "2"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.content.length()").value(1))
                    .andExpect(jsonPath("$.page").value(1))
                    .andExpect(jsonPath("$.size").value(2))
                    .andExpect(jsonPath("$.totalElements").value(5))
                    .andExpect(jsonPath("$.totalPages").value(3));

            verify(service).getAllCustomersPaged(1, 2);
        }

        @ParameterizedTest(name = "Should handle pagination with page={0} and size={1}")
        @MethodSource("com.example.demo.CustomerControllerTest#invalidPaginationProvider")
        @DisplayName("Should handle edge case pagination parameters gracefully")
        void shouldHandleEdgeCasePaginationParameters(int page, int size, String description) throws Exception {
            // Arrange
            PageResponse<Customer> emptyResponse = new PageResponse<>(List.of(), page, size, 0, 0);
            when(service.getAllCustomersPaged(page, size)).thenReturn(emptyResponse);

            // Act & Assert
            mockMvc.perform(get("/api/v1/customers")
                            .param("page", String.valueOf(page))
                            .param("size", String.valueOf(size)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.content").isArray())
                    .andExpect(jsonPath("$.page").value(page))
                    .andExpect(jsonPath("$.size").value(size));

            verify(service).getAllCustomersPaged(page, size);
        }
    }

    @Nested
    @DisplayName("GET /api/v1/customers/{id} - Get Customer by ID")
    class GetCustomerByIdTests {

        @Test
        @DisplayName("Should return customer when found")
        void shouldReturnCustomerWhenFound() throws Exception {
            // Arrange
            Customer customer = CustomerTestBuilder.validCustomer();
            when(service.getCustomer("1")).thenReturn(Optional.of(customer));

            // Act & Assert
            mockMvc.perform(get("/api/v1/customers/1"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.id").value("1"))
                    .andExpect(jsonPath("$.name").value("John Doe"));

            verify(service).getCustomer("1");
        }

        @Test
        @DisplayName("Should return 404 when customer does not exist")
        void shouldReturnNotFoundWhenCustomerDoesNotExist() throws Exception {
            // Arrange
            when(service.getCustomer("99")).thenReturn(Optional.empty());

            // Act & Assert
            mockMvc.perform(get("/api/v1/customers/99"))
                    .andExpect(status().isNotFound());

            verify(service).getCustomer("99");
        }
    }

    @Nested
    @DisplayName("POST /api/v1/customers - Create Customer")
    class CreateCustomerTests {

        @Test
        @DisplayName("Should create customer and return 201 Created")
        void shouldCreateCustomer() throws Exception {
            // Arrange
            Customer input = CustomerTestBuilder.validCustomerInput();
            Customer output = CustomerTestBuilder.customer("2", "Jane Doe", "jane@example.com");
            when(service.addCustomer(any(Customer.class))).thenReturn(output);

            // Act & Assert
            mockMvc.perform(post("/api/v1/customers")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(input)))
                    .andExpect(status().isCreated())
                    .andExpect(jsonPath("$.id").value("2"))
                    .andExpect(jsonPath("$.name").value("Jane Doe"));

            verify(service).addCustomer(any(Customer.class));
        }

        @Test
        @DisplayName("Should return 400 when validation fails with multiple errors")
        void shouldReturnBadRequestWhenValidationFails() throws Exception {
            // Arrange
            Customer input = CustomerTestBuilder.invalidCustomer();

            // Act & Assert
            mockMvc.perform(post("/api/v1/customers")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(input)))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.status").value(400))
                    .andExpect(jsonPath("$.message").value("Validation failed"))
                    .andExpect(jsonPath("$.errors").isArray());

            verify(service, never()).addCustomer(any());
        }
    }

    @Nested
    @DisplayName("PUT /api/v1/customers/{id} - Update Customer")
    class UpdateCustomerTests {

        @Test
        @DisplayName("Should update customer when exists")
        void shouldUpdateCustomerWhenExists() throws Exception {
            // Arrange
            Customer input = CustomerTestBuilder.updateInput();
            Customer output = CustomerTestBuilder.updatedCustomer("1");
            when(service.updateCustomer(eq("1"), any(Customer.class))).thenReturn(Optional.of(output));

            // Act & Assert
            mockMvc.perform(put("/api/v1/customers/1")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(input)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.id").value("1"))
                    .andExpect(jsonPath("$.name").value("John Updated"));

            verify(service).updateCustomer(eq("1"), any(Customer.class));
        }

        @Test
        @DisplayName("Should return 404 when updating non-existent customer")
        void shouldReturnNotFoundWhenUpdatingNonExistentCustomer() throws Exception {
            // Arrange
            Customer input = CustomerTestBuilder.customerInput("Ghost", "ghost@example.com");
            when(service.updateCustomer(eq("99"), any(Customer.class))).thenReturn(Optional.empty());

            // Act & Assert
            mockMvc.perform(put("/api/v1/customers/99")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(input)))
                    .andExpect(status().isNotFound());

            verify(service).updateCustomer(eq("99"), any(Customer.class));
        }

        @Test
        @DisplayName("Should return 400 when update validation fails")
        void shouldValidateOnUpdate() throws Exception {
            // Arrange
            Customer input = CustomerTestBuilder.invalidCustomer();

            // Act & Assert
            mockMvc.perform(put("/api/v1/customers/1")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(input)))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.message").value("Validation failed"))
                    .andExpect(jsonPath("$.errors").isArray());

            verify(service, never()).updateCustomer(any(), any());
        }
    }

    @Nested
    @DisplayName("DELETE /api/v1/customers/{id} - Delete Customer")
    class DeleteCustomerTests {

        @Test
        @DisplayName("Should delete customer and return 204 No Content")
        void shouldDeleteCustomerWhenExists() throws Exception {
            // Arrange
            when(service.deleteCustomer("1")).thenReturn(true);

            // Act & Assert
            mockMvc.perform(delete("/api/v1/customers/1"))
                    .andExpect(status().isNoContent());

            verify(service).deleteCustomer("1");
        }

        @Test
        @DisplayName("Should return 404 when deleting non-existent customer")
        void shouldReturnNotFoundWhenDeletingNonExistentCustomer() throws Exception {
            // Arrange
            when(service.deleteCustomer("99")).thenReturn(false);

            // Act & Assert
            mockMvc.perform(delete("/api/v1/customers/99"))
                    .andExpect(status().isNotFound());

            verify(service).deleteCustomer("99");
        }
    }

    @Nested
    @DisplayName("Validation Tests - Parameterized")
    class ValidationTests {

        @ParameterizedTest(name = "Should return 400 for invalid input: {0}")
        @MethodSource("com.example.demo.CustomerControllerTest#invalidCustomerProvider")
        @DisplayName("Should return 400 Bad Request for various invalid inputs")
        void shouldReturnBadRequestForInvalidCustomer(
                String testName,
                Customer invalidCustomer,
                String expectedField) throws Exception {

            // Act & Assert
            mockMvc.perform(post("/api/v1/customers")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(invalidCustomer)))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.errors[?(@.field == '" + expectedField + "')]").exists());

            verify(service, never()).addCustomer(any());
        }

        @ParameterizedTest(name = "Should return 400 on update for invalid input: {0}")
        @MethodSource("com.example.demo.CustomerControllerTest#invalidCustomerProvider")
        @DisplayName("Should return 400 Bad Request on update for various invalid inputs")
        void shouldReturnBadRequestOnUpdateForInvalidCustomer(
                String testName,
                Customer invalidCustomer,
                String expectedField) throws Exception {

            // Act & Assert
            mockMvc.perform(put("/api/v1/customers/1")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(invalidCustomer)))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.errors[?(@.field == '" + expectedField + "')]").exists());

            verify(service, never()).updateCustomer(any(), any());
        }
    }

    @Nested
    @DisplayName("Error Handling Tests")
    class ErrorHandlingTests {

        @Test
        @DisplayName("Should return 500 Internal Server Error on RuntimeException")
        void shouldReturnInternalServerErrorOnRuntimeException() throws Exception {
            // Arrange
            when(service.getAllCustomersPaged(0, 20))
                    .thenThrow(new RuntimeException("Database connection failed"));

            // Act & Assert
            mockMvc.perform(get("/api/v1/customers"))
                    .andExpect(status().isInternalServerError())
                    .andExpect(jsonPath("$.status").value(500))
                    .andExpect(jsonPath("$.message").value("Database connection failed"));

            verify(service).getAllCustomersPaged(0, 20);
        }
    }

    /**
     * Provides invalid customer data for parameterized validation tests.
     *
     * @return Stream of test arguments with test name, invalid customer, and expected error field
     */
    static Stream<Arguments> invalidCustomerProvider() {
        return Stream.of(
                Arguments.of(
                        "blank name",
                        CustomerTestBuilder.customerWithBlankName(),
                        "name"
                ),
                Arguments.of(
                        "invalid email format",
                        CustomerTestBuilder.customerWithInvalidEmail(),
                        "email"
                ),
                Arguments.of(
                        "null name",
                        CustomerTestBuilder.customerWithNullName(),
                        "name"
                ),
                Arguments.of(
                        "null email",
                        CustomerTestBuilder.customerWithNullEmail(),
                        "email"
                )
        );
    }

    /**
     * Provides edge case pagination parameters for parameterized tests.
     *
     * @return Stream of test arguments with page, size, and description
     */
    static Stream<Arguments> invalidPaginationProvider() {
        return Stream.of(
                Arguments.of(0, 1, "minimum valid size"),
                Arguments.of(0, 100, "large page size"),
                Arguments.of(999, 20, "very high page number")
        );
    }
}
