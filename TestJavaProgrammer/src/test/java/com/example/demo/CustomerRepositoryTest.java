package com.example.demo;

import com.example.demo.model.Customer;
import com.example.demo.repository.CustomerRepository;
import com.example.demo.testutil.CustomerTestBuilder;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.io.File;
import java.nio.file.Path;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Integration tests for CustomerRepository.
 * Tests JSON file persistence with actual file I/O using temporary directories.
 */
@DisplayName("CustomerRepository Integration Tests")
class CustomerRepositoryTest {

    @TempDir
    Path tempDir;

    private CustomerRepository repository;
    private ObjectMapper objectMapper;
    private File testFile;

    @BeforeEach
    void setUp() {
        objectMapper = new ObjectMapper();
        testFile = tempDir.resolve("test-customers.json").toFile();
        repository = new CustomerRepository(objectMapper, testFile.getAbsolutePath());
    }

    @AfterEach
    void tearDown() {
        if (testFile.exists()) {
            testFile.delete();
        }
    }

    @Nested
    @DisplayName("Initialization Tests")
    class InitializationTests {

        @Test
        @DisplayName("Should initialize with empty JSON file on construction")
        void shouldInitializeEmptyFileOnConstruction() {
            // Assert
            assertThat(testFile).exists();
            List<Customer> customers = repository.findAll();
            assertThat(customers).isEmpty();
        }
    }

    @Nested
    @DisplayName("Save and Retrieve Tests")
    class SaveAndRetrieveTests {

        @Test
        @DisplayName("Should save customer and retrieve by ID")
        void shouldSaveAndRetrieveCustomer() {
            // Arrange
            Customer customer = CustomerTestBuilder.validCustomer();

            // Act
            Customer saved = repository.save(customer);
            Optional<Customer> found = repository.findById("1");

            // Assert
            assertThat(saved.id()).isEqualTo("1");
            assertThat(found).isPresent();
            assertThat(found.get().name()).isEqualTo("John Doe");
            assertThat(found.get().email()).isEqualTo("john@example.com");
        }

        @Test
        @DisplayName("Should return all saved customers")
        void shouldReturnAllSavedCustomers() {
            // Arrange
            repository.save(CustomerTestBuilder.validCustomer());
            repository.save(CustomerTestBuilder.secondCustomer());
            repository.save(CustomerTestBuilder.thirdCustomer());

            // Act
            List<Customer> customers = repository.findAll();

            // Assert
            assertThat(customers).hasSize(3);
            assertThat(customers).extracting(Customer::name)
                    .containsExactlyInAnyOrder("John Doe", "Jane Doe", "Bob Smith");
        }

        @Test
        @DisplayName("Should return empty Optional when customer not found")
        void shouldReturnEmptyOptionalWhenCustomerNotFound() {
            // Arrange
            repository.save(CustomerTestBuilder.validCustomer());

            // Act
            Optional<Customer> found = repository.findById("99");

            // Assert
            assertThat(found).isEmpty();
        }
    }

    @Nested
    @DisplayName("Update Tests")
    class UpdateTests {

        @Test
        @DisplayName("Should update existing customer with same ID")
        void shouldUpdateExistingCustomer() {
            // Arrange
            repository.save(CustomerTestBuilder.validCustomer());

            // Act
            Customer updated = CustomerTestBuilder.updatedCustomer("1");
            repository.save(updated);
            Optional<Customer> found = repository.findById("1");

            // Assert
            assertThat(found).isPresent();
            assertThat(found.get().name()).isEqualTo("John Updated");
            assertThat(found.get().email()).isEqualTo("john.updated@example.com");
            assertThat(repository.findAll()).hasSize(1);
        }

        @Test
        @DisplayName("Should keep only latest version when saving multiple times with same ID")
        void shouldHandleMultipleSavesWithSameId() {
            // Arrange & Act
            repository.save(CustomerTestBuilder.customer("1", "Version 1", "v1@example.com"));
            repository.save(CustomerTestBuilder.customer("1", "Version 2", "v2@example.com"));
            repository.save(CustomerTestBuilder.customer("1", "Version 3", "v3@example.com"));

            // Assert
            List<Customer> customers = repository.findAll();
            assertThat(customers).hasSize(1);
            assertThat(customers.get(0).name()).isEqualTo("Version 3");
        }
    }

    @Nested
    @DisplayName("Delete Tests")
    class DeleteTests {

        @Test
        @DisplayName("Should delete existing customer and return true")
        void shouldDeleteExistingCustomer() {
            // Arrange
            repository.save(CustomerTestBuilder.validCustomer());
            repository.save(CustomerTestBuilder.secondCustomer());

            // Act
            boolean deleted = repository.deleteById("1");

            // Assert
            assertThat(deleted).isTrue();
            assertThat(repository.findAll()).hasSize(1);
            assertThat(repository.findById("1")).isEmpty();
            assertThat(repository.findById("2")).isPresent();
        }

        @Test
        @DisplayName("Should return false when deleting non-existent customer")
        void shouldReturnFalseWhenDeletingNonExistentCustomer() {
            // Arrange
            repository.save(CustomerTestBuilder.validCustomer());

            // Act
            boolean deleted = repository.deleteById("99");

            // Assert
            assertThat(deleted).isFalse();
            assertThat(repository.findAll()).hasSize(1);
        }
    }

    @Nested
    @DisplayName("Persistence Tests")
    class PersistenceTests {

        @Test
        @DisplayName("Should persist data across repository instances")
        void shouldPersistDataAcrossRepositoryInstances() {
            // Arrange
            repository.save(CustomerTestBuilder.validCustomer());

            // Act - create new repository instance pointing to same file
            CustomerRepository newRepository = new CustomerRepository(objectMapper, testFile.getAbsolutePath());
            List<Customer> customers = newRepository.findAll();

            // Assert
            assertThat(customers).hasSize(1);
            assertThat(customers.get(0).name()).isEqualTo("John Doe");
        }

        @Test
        @DisplayName("Should preserve special characters in customer data")
        void shouldPreserveCustomerDataIntegrity() {
            // Arrange
            Customer customer = CustomerTestBuilder.customer(
                    "test-id-123",
                    "Test Name With Special Chars: åäö",
                    "test+special@example.com"
            );

            // Act
            repository.save(customer);
            Optional<Customer> found = repository.findById("test-id-123");

            // Assert
            assertThat(found).isPresent();
            assertThat(found.get().id()).isEqualTo("test-id-123");
            assertThat(found.get().name()).isEqualTo("Test Name With Special Chars: åäö");
            assertThat(found.get().email()).isEqualTo("test+special@example.com");
        }
    }

    @Nested
    @DisplayName("Empty Repository Tests")
    class EmptyRepositoryTests {

        @Test
        @DisplayName("Should handle operations on empty repository gracefully")
        void shouldHandleEmptyRepository() {
            // Act
            List<Customer> customers = repository.findAll();
            Optional<Customer> found = repository.findById("1");
            boolean deleted = repository.deleteById("1");

            // Assert
            assertThat(customers).isEmpty();
            assertThat(found).isEmpty();
            assertThat(deleted).isFalse();
        }
    }
}
