package com.example.demo.testutil;

import com.example.demo.model.Customer;

/**
 * Test Data Builder for Customer objects.
 * Provides factory methods for creating test data to reduce duplication
 * and improve test maintainability.
 */
public final class CustomerTestBuilder {

    private CustomerTestBuilder() {
        // Utility class - prevent instantiation
    }

    // ==================== Valid Customers ====================

    /**
     * Creates a valid customer with default test data.
     *
     * @return a valid Customer with id "1"
     */
    public static Customer validCustomer() {
        return new Customer("1", "John Doe", "john@example.com");
    }

    /**
     * Creates a valid customer with a specific ID.
     *
     * @param id the customer ID
     * @return a valid Customer with the specified ID
     */
    public static Customer validCustomerWithId(String id) {
        return new Customer(id, "John Doe", "john@example.com");
    }

    /**
     * Creates a valid customer with specific values.
     *
     * @param id    the customer ID
     * @param name  the customer name
     * @param email the customer email
     * @return a Customer with the specified values
     */
    public static Customer customer(String id, String name, String email) {
        return new Customer(id, name, email);
    }

    /**
     * Creates a valid customer input without ID (for creation requests).
     *
     * @return a Customer with null ID suitable for POST requests
     */
    public static Customer validCustomerInput() {
        return new Customer(null, "Jane Doe", "jane@example.com");
    }

    /**
     * Creates a valid customer input with specific name and email.
     *
     * @param name  the customer name
     * @param email the customer email
     * @return a Customer with null ID
     */
    public static Customer customerInput(String name, String email) {
        return new Customer(null, name, email);
    }

    // ==================== Invalid Customers ====================

    /**
     * Creates an invalid customer with blank name and invalid email.
     *
     * @return an invalid Customer for validation testing
     */
    public static Customer invalidCustomer() {
        return new Customer(null, "", "invalid-email");
    }

    /**
     * Creates a customer with blank name (validation failure).
     *
     * @return a Customer with blank name
     */
    public static Customer customerWithBlankName() {
        return new Customer(null, "", "valid@example.com");
    }

    /**
     * Creates a customer with invalid email format.
     *
     * @return a Customer with invalid email
     */
    public static Customer customerWithInvalidEmail() {
        return new Customer(null, "Valid Name", "not-an-email");
    }

    /**
     * Creates a customer with null name.
     *
     * @return a Customer with null name
     */
    public static Customer customerWithNullName() {
        return new Customer(null, null, "valid@example.com");
    }

    /**
     * Creates a customer with null email.
     *
     * @return a Customer with null email
     */
    public static Customer customerWithNullEmail() {
        return new Customer(null, "Valid Name", null);
    }

    // ==================== Sample Data Sets ====================

    /**
     * Creates a second valid customer for list tests.
     *
     * @return a valid Customer with id "2"
     */
    public static Customer secondCustomer() {
        return new Customer("2", "Jane Doe", "jane@example.com");
    }

    /**
     * Creates a third valid customer for list tests.
     *
     * @return a valid Customer with id "3"
     */
    public static Customer thirdCustomer() {
        return new Customer("3", "Bob Smith", "bob@example.com");
    }

    /**
     * Creates an updated version of a customer.
     *
     * @param id the customer ID to preserve
     * @return an updated Customer
     */
    public static Customer updatedCustomer(String id) {
        return new Customer(id, "John Updated", "john.updated@example.com");
    }

    /**
     * Creates an update input (without ID) for PUT requests.
     *
     * @return a Customer update input
     */
    public static Customer updateInput() {
        return new Customer(null, "John Updated", "john.updated@example.com");
    }
}
