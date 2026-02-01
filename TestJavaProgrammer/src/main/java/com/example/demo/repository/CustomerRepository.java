package com.example.demo.repository;

import com.example.demo.model.Customer;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Repository;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Repository for persisting Customer data to a local JSON file.
 * Provides CRUD operations with thread-safe access.
 */
@Repository
public class CustomerRepository implements CustomerRepositoryInterface {

    private final ObjectMapper objectMapper;
    private final File file;

    /**
     * Constructs a CustomerRepository with the specified ObjectMapper and file path.
     * Initializes the data file if it does not exist.
     *
     * @param objectMapper the Jackson ObjectMapper for JSON serialization
     * @param filePath     the path to the JSON file for storing customer data
     * @throws RuntimeException if the file cannot be initialized
     */
    public CustomerRepository(
            ObjectMapper objectMapper,
            @Value("${app.data.file:customers.json}") String filePath) {
        this.objectMapper = objectMapper;
        this.file = new File(filePath);
        if (!file.exists()) {
            try {
                objectMapper.writeValue(file, new ArrayList<Customer>());
            } catch (IOException e) {
                throw new RuntimeException("Could not initialize customer file", e);
            }
        }
    }

    /**
     * Retrieves all customers from the data file.
     *
     * @return a list of all customers
     * @throws RuntimeException if the file cannot be read
     */
    @Override
    public synchronized List<Customer> findAll() {
        try {
            return objectMapper.readValue(file, new TypeReference<List<Customer>>() {});
        } catch (IOException e) {
            throw new RuntimeException("Failed to read customers", e);
        }
    }

    /**
     * Finds a customer by their unique identifier.
     *
     * @param id the unique identifier of the customer
     * @return an Optional containing the customer if found, or empty if not found
     */
    @Override
    public synchronized Optional<Customer> findById(String id) {
        return findAll().stream()
                .filter(c -> c.id().equals(id))
                .findFirst();
    }

    /**
     * Saves a customer to the data file. If a customer with the same ID exists,
     * it will be replaced (upsert behavior).
     *
     * @param customer the customer to save
     * @return the saved customer
     * @throws RuntimeException if the file cannot be written
     */
    @Override
    public synchronized Customer save(Customer customer) {
        List<Customer> customers = findAll();
        customers.removeIf(c -> c.id().equals(customer.id()));
        customers.add(customer);
        writeCustomers(customers);
        return customer;
    }

    /**
     * Deletes a customer by their unique identifier.
     *
     * @param id the unique identifier of the customer to delete
     * @return true if the customer was deleted, false if not found
     * @throws RuntimeException if the file cannot be written
     */
    @Override
    public synchronized boolean deleteById(String id) {
        List<Customer> customers = findAll();
        boolean removed = customers.removeIf(c -> c.id().equals(id));
        if (removed) {
            writeCustomers(customers);
        }
        return removed;
    }

    /**
     * Writes the list of customers to the data file.
     *
     * @param customers the list of customers to persist
     * @throws RuntimeException if the file cannot be written
     */
    private void writeCustomers(List<Customer> customers) {
        try {
            objectMapper.writeValue(file, customers);
        } catch (IOException e) {
            throw new RuntimeException("Failed to write customers", e);
        }
    }
}
