package com.example.demo.repository;

import com.example.demo.model.Customer;

import java.util.List;
import java.util.Optional;

/**
 * Interface for Customer repository operations.
 * Defines CRUD operations for Customer entities.
 * 
 * <p>This interface allows for easier mocking in unit tests and provides
 * abstraction over the actual data storage implementation.</p>
 */
public interface CustomerRepositoryInterface {

    /**
     * Retrieves all customers.
     *
     * @return a list of all customers
     */
    List<Customer> findAll();

    /**
     * Finds a customer by their unique identifier.
     *
     * @param id the unique identifier of the customer
     * @return an Optional containing the customer if found, or empty if not found
     */
    Optional<Customer> findById(String id);

    /**
     * Saves a customer. If a customer with the same ID exists,
     * it will be replaced (upsert behavior).
     *
     * @param customer the customer to save
     * @return the saved customer
     */
    Customer save(Customer customer);

    /**
     * Deletes a customer by their unique identifier.
     *
     * @param id the unique identifier of the customer to delete
     * @return true if the customer was deleted, false if not found
     */
    boolean deleteById(String id);
}
