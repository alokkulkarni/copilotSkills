package com.example.demo.exception;

/**
 * Custom exception for data storage operations.
 * Thrown when file-based storage operations fail.
 */
public class DataStorageException extends RuntimeException {

    /**
     * Constructs a DataStorageException with a message.
     *
     * @param message the error message
     */
    public DataStorageException(String message) {
        super(message);
    }

    /**
     * Constructs a DataStorageException with a message and cause.
     *
     * @param message the error message
     * @param cause   the underlying cause
     */
    public DataStorageException(String message, Throwable cause) {
        super(message, cause);
    }
}
