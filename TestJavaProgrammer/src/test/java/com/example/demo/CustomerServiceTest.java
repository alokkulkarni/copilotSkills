package com.example.demo;

import com.example.demo.model.Customer;
import com.example.demo.model.PageResponse;
import com.example.demo.repository.CustomerRepositoryInterface;
import com.example.demo.service.CustomerService;
import com.example.demo.testutil.CustomerTestBuilder;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Unit tests for CustomerService.
 * Tests business logic and service layer functionality.
 * 
 * <p>Uses the interface {@link CustomerRepositoryInterface} for mocking to avoid
 * Mockito limitations with concrete classes that have constructor dependencies.</p>
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("CustomerService Unit Tests")
class CustomerServiceTest {

    @Mock
    private CustomerRepositoryInterface repository;

    private CustomerService service;

    @BeforeEach
    void setUp() {
        service = new CustomerService(repository);
    }

    @Nested
    @DisplayName("Get All Customers Tests")
    class GetAllCustomersTests {

        @Test
        @DisplayName("Should return all customers from repository")
        void shouldReturnAllCustomers() {
            // Arrange
            List<Customer> customers = List.of(
                    CustomerTestBuilder.validCustomer(),
                    CustomerTestBuilder.secondCustomer()
            );
            when(repository.findAll()).thenReturn(customers);

            // Act
            List<Customer> result = service.getAllCustomers();

            // Assert
            assertThat(result).hasSize(2);
            assertThat(result.get(0).name()).isEqualTo("John Doe");
            verify(repository).findAll();
        }

        @Test
        @DisplayName("Should return paginated customers for first page")
        void shouldReturnPaginatedCustomers() {
            // Arrange
            List<Customer> customers = List.of(
                    CustomerTestBuilder.validCustomer(),
                    CustomerTestBuilder.secondCustomer(),
                    CustomerTestBuilder.thirdCustomer()
            );
            when(repository.findAll()).thenReturn(customers);

            // Act
            List<Customer> result = service.getAllCustomers(0, 2);

            // Assert
            assertThat(result).hasSize(2);
            assertThat(result.get(0).id()).isEqualTo("1");
            assertThat(result.get(1).id()).isEqualTo("2");
        }

        @Test
        @DisplayName("Should return correct customers for second page")
        void shouldReturnSecondPage() {
            // Arrange
            List<Customer> customers = List.of(
                    CustomerTestBuilder.validCustomer(),
                    CustomerTestBuilder.secondCustomer(),
                    CustomerTestBuilder.thirdCustomer()
            );
            when(repository.findAll()).thenReturn(customers);

            // Act
            List<Customer> result = service.getAllCustomers(1, 2);

            // Assert
            assertThat(result).hasSize(1);
            assertThat(result.get(0).id()).isEqualTo("3");
        }

        @Test
        @DisplayName("Should return empty list when page exceeds available data")
        void shouldReturnEmptyListWhenPageExceedsData() {
            // Arrange
            List<Customer> customers = List.of(CustomerTestBuilder.validCustomer());
            when(repository.findAll()).thenReturn(customers);

            // Act
            List<Customer> result = service.getAllCustomers(5, 10);

            // Assert
            assertThat(result).isEmpty();
        }

        @Test
        @DisplayName("Should return paged response with correct metadata")
        void shouldReturnPagedResponseWithMetadata() {
            // Arrange
            List<Customer> customers = List.of(
                    CustomerTestBuilder.customer("1", "John Doe", "john@example.com"),
                    CustomerTestBuilder.customer("2", "Jane Doe", "jane@example.com"),
                    CustomerTestBuilder.customer("3", "Bob Smith", "bob@example.com"),
                    CustomerTestBuilder.customer("4", "Alice Brown", "alice@example.com"),
                    CustomerTestBuilder.customer("5", "Charlie Green", "charlie@example.com")
            );
            when(repository.findAll()).thenReturn(customers);

            // Act
            PageResponse<Customer> result = service.getAllCustomersPaged(0, 2);

            // Assert
            assertThat(result.content()).hasSize(2);
            assertThat(result.page()).isEqualTo(0);
            assertThat(result.size()).isEqualTo(2);
            assertThat(result.totalElements()).isEqualTo(5);
            assertThat(result.totalPages()).isEqualTo(3);
        }
    }

    @Nested
    @DisplayName("Get Customer By ID Tests")
    class GetCustomerByIdTests {

        @Test
        @DisplayName("Should return customer when found by ID")
        void shouldReturnCustomerById() {
            // Arrange
            Customer customer = CustomerTestBuilder.validCustomer();
            when(repository.findById("1")).thenReturn(Optional.of(customer));

            // Act
            Optional<Customer> result = service.getCustomer("1");

            // Assert
            assertThat(result).isPresent();
            assertThat(result.get().name()).isEqualTo("John Doe");
            verify(repository).findById("1");
        }

        @Test
        @DisplayName("Should return empty when customer not found")
        void shouldReturnEmptyWhenCustomerNotFound() {
            // Arrange
            when(repository.findById("99")).thenReturn(Optional.empty());

            // Act
            Optional<Customer> result = service.getCustomer("99");

            // Assert
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("Add Customer Tests")
    class AddCustomerTests {

        @Test
        @DisplayName("Should generate UUID when ID is null")
        void shouldAddCustomerWithGeneratedId() {
            // Arrange
            Customer input = CustomerTestBuilder.customerInput("New Customer", "new@example.com");
            when(repository.save(any(Customer.class))).thenAnswer(invocation -> invocation.getArgument(0));

            // Act
            Customer result = service.addCustomer(input);

            // Assert
            assertThat(result.id()).isNotNull();
            assertThat(result.id()).isNotBlank();
            assertThat(result.name()).isEqualTo("New Customer");
            verify(repository).save(any(Customer.class));
        }

        @Test
        @DisplayName("Should preserve provided ID when not null")
        void shouldAddCustomerWithProvidedId() {
            // Arrange
            Customer input = CustomerTestBuilder.customer("custom-id", "New Customer", "new@example.com");
            when(repository.save(any(Customer.class))).thenAnswer(invocation -> invocation.getArgument(0));

            // Act
            Customer result = service.addCustomer(input);

            // Assert
            assertThat(result.id()).isEqualTo("custom-id");
            assertThat(result.name()).isEqualTo("New Customer");
            verify(repository).save(input);
        }

        @Test
        @DisplayName("Should generate UUID when ID is blank string")
        void shouldGenerateIdWhenIdIsBlank() {
            // Arrange
            Customer input = CustomerTestBuilder.customer("", "New Customer", "new@example.com");
            when(repository.save(any(Customer.class))).thenAnswer(invocation -> invocation.getArgument(0));

            // Act
            Customer result = service.addCustomer(input);

            // Assert
            assertThat(result.id()).isNotNull();
            assertThat(result.id()).isNotBlank();
            assertThat(result.id()).isNotEqualTo("");
        }
    }

    @Nested
    @DisplayName("Update Customer Tests")
    class UpdateCustomerTests {

        @Test
        @DisplayName("Should update and return customer when exists")
        void shouldUpdateExistingCustomer() {
            // Arrange
            Customer existing = CustomerTestBuilder.validCustomer();
            Customer update = CustomerTestBuilder.updateInput();
            when(repository.findById("1")).thenReturn(Optional.of(existing));
            when(repository.save(any(Customer.class))).thenAnswer(invocation -> invocation.getArgument(0));

            // Act
            Optional<Customer> result = service.updateCustomer("1", update);

            // Assert
            assertThat(result).isPresent();
            assertThat(result.get().id()).isEqualTo("1");
            assertThat(result.get().name()).isEqualTo("John Updated");
            assertThat(result.get().email()).isEqualTo("john.updated@example.com");
        }

        @Test
        @DisplayName("Should return empty when updating non-existent customer")
        void shouldReturnEmptyWhenUpdatingNonExistentCustomer() {
            // Arrange
            Customer update = CustomerTestBuilder.customerInput("Ghost", "ghost@example.com");
            when(repository.findById("99")).thenReturn(Optional.empty());

            // Act
            Optional<Customer> result = service.updateCustomer("99", update);

            // Assert
            assertThat(result).isEmpty();
            verify(repository, never()).save(any());
        }
    }

    @Nested
    @DisplayName("Delete Customer Tests")
    class DeleteCustomerTests {

        @Test
        @DisplayName("Should return true when customer deleted successfully")
        void shouldDeleteExistingCustomer() {
            // Arrange
            when(repository.deleteById("1")).thenReturn(true);

            // Act
            boolean result = service.deleteCustomer("1");

            // Assert
            assertThat(result).isTrue();
            verify(repository).deleteById("1");
        }

        @Test
        @DisplayName("Should return false when deleting non-existent customer")
        void shouldReturnFalseWhenDeletingNonExistentCustomer() {
            // Arrange
            when(repository.deleteById("99")).thenReturn(false);

            // Act
            boolean result = service.deleteCustomer("99");

            // Assert
            assertThat(result).isFalse();
        }
    }
}
