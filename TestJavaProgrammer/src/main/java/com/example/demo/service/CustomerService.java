package com.example.demo.service;

import com.example.demo.model.Customer;
import com.example.demo.model.PageResponse;
import com.example.demo.repository.CustomerRepositoryInterface;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Service layer for customer business logic.
 * Handles operations such as retrieving, creating, updating, and deleting customers.
 */
@Service
public class CustomerService implements CustomerServiceInterface {

    private final CustomerRepositoryInterface repository;

    /**
     * Constructs a CustomerService with the required repository.
     *
     * @param repository the customer repository for data access
     */
    public CustomerService(CustomerRepositoryInterface repository) {
        this.repository = repository;
    }

    /**
     * Retrieves all customers from the repository.
     *
     * @return a list of all customers
     */
    @Override
    public List<Customer> getAllCustomers() {
        return repository.findAll();
    }

    /**
     * Retrieves a paginated list of customers.
     *
     * @param page the page number (zero-based)
     * @param size the number of records per page
     * @return a list of customers for the requested page, or empty list if page exceeds data
     */
    @Override
    public List<Customer> getAllCustomers(int page, int size) {
        List<Customer> all = repository.findAll();
        int start = page * size;
        if (start >= all.size()) {
            return List.of();
        }
        int end = Math.min(start + size, all.size());
        return all.subList(start, end);
    }

    /**
     * Retrieves a paginated response of customers with metadata.
     *
     * @param page the page number (zero-based)
     * @param size the number of records per page
     * @return a PageResponse containing customers and pagination metadata
     */
    @Override
    public PageResponse<Customer> getAllCustomersPaged(int page, int size) {
        List<Customer> all = repository.findAll();
        return PageResponse.of(all, page, size);
    }

    /**
     * Retrieves a customer by their unique identifier.
     *
     * @param id the unique identifier of the customer
     * @return an Optional containing the customer if found, or empty if not found
     */
    @Override
    public Optional<Customer> getCustomer(String id) {
        return repository.findById(id);
    }

    /**
     * Adds a new customer. If the customer ID is null or blank, a UUID is generated.
     *
     * @param customer the customer to add
     * @return the saved customer with its assigned ID
     */
    @Override
    public Customer addCustomer(Customer customer) {
        String id = customer.id();
        if (id == null || id.isBlank()) {
            id = UUID.randomUUID().toString();
            customer = new Customer(id, customer.name(), customer.email());
        }
        return repository.save(customer);
    }

    /**
     * Updates an existing customer.
     *
     * @param id       the unique identifier of the customer to update
     * @param customer the updated customer data
     * @return an Optional containing the updated customer if found, or empty if not found
     */
    @Override
    public Optional<Customer> updateCustomer(String id, Customer customer) {
        Optional<Customer> existing = repository.findById(id);
        if (existing.isPresent()) {
            Customer updated = new Customer(id, customer.name(), customer.email());
            return Optional.of(repository.save(updated));
        }
        return Optional.empty();
    }

    /**
     * Deletes a customer by their unique identifier.
     *
     * @param id the unique identifier of the customer to delete
     * @return true if the customer was deleted, false if not found
     */
    @Override
    public boolean deleteCustomer(String id) {
        return repository.deleteById(id);
    }
}
