package com.example.demo.service;

import com.example.demo.model.Customer;
import com.example.demo.model.PageResponse;

import java.util.List;
import java.util.Optional;

/**
 * Interface for Customer service operations.
 * Defines business operations for Customer entities.
 *
 * <p>This interface allows for easier mocking in unit tests and provides
 * abstraction over the actual service implementation.</p>
 */
public interface CustomerServiceInterface {

    /**
     * Retrieves all customers.
     *
     * @return a list of all customers
     */
    List<Customer> getAllCustomers();

    /**
     * Retrieves a paginated list of customers.
     *
     * @param page the page number (zero-based)
     * @param size the number of records per page
     * @return a list of customers for the requested page
     */
    List<Customer> getAllCustomers(int page, int size);

    /**
     * Retrieves a paginated response of customers with metadata.
     *
     * @param page the page number (zero-based)
     * @param size the number of records per page
     * @return a PageResponse containing customers and pagination metadata
     */
    PageResponse<Customer> getAllCustomersPaged(int page, int size);

    /**
     * Retrieves a customer by their unique identifier.
     *
     * @param id the unique identifier of the customer
     * @return an Optional containing the customer if found, or empty if not found
     */
    Optional<Customer> getCustomer(String id);

    /**
     * Adds a new customer.
     *
     * @param customer the customer to add
     * @return the saved customer with its assigned ID
     */
    Customer addCustomer(Customer customer);

    /**
     * Updates an existing customer.
     *
     * @param id       the unique identifier of the customer to update
     * @param customer the updated customer data
     * @return an Optional containing the updated customer if found, or empty if not found
     */
    Optional<Customer> updateCustomer(String id, Customer customer);

    /**
     * Deletes a customer by their unique identifier.
     *
     * @param id the unique identifier of the customer to delete
     * @return true if the customer was deleted, false if not found
     */
    boolean deleteCustomer(String id);
}
