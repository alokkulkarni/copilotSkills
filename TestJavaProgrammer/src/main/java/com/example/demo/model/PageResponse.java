package com.example.demo.model;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/**
 * A generic wrapper for paginated API responses.
 * Contains the content along with pagination metadata.
 *
 * @param content       the list of items for the current page
 * @param page          the current page number (zero-based)
 * @param size          the number of items per page
 * @param totalElements the total number of items across all pages
 * @param totalPages    the total number of pages
 * @param <T>           the type of items in the content list
 */
@Schema(description = "Paginated response containing items and pagination metadata")
public record PageResponse<T>(
        @Schema(description = "List of items for the current page")
        List<T> content,
        
        @Schema(description = "Current page number (zero-based)", example = "0")
        int page,
        
        @Schema(description = "Number of items per page", example = "20")
        int size,
        
        @Schema(description = "Total number of items across all pages", example = "42")
        long totalElements,
        
        @Schema(description = "Total number of pages", example = "3")
        int totalPages
) {

    /**
     * Creates a PageResponse from a full list with pagination parameters.
     *
     * @param allItems the complete list of items
     * @param page     the requested page number (zero-based)
     * @param size     the number of items per page
     * @param <T>      the type of items
     * @return a PageResponse containing the paginated content and metadata
     */
    public static <T> PageResponse<T> of(List<T> allItems, int page, int size) {
        int totalElements = allItems.size();
        int totalPages = (int) Math.ceil((double) totalElements / size);
        int start = page * size;
        List<T> content;
        if (start >= totalElements) {
            content = List.of();
        } else {
            int end = Math.min(start + size, totalElements);
            content = allItems.subList(start, end);
        }
        return new PageResponse<>(content, page, size, totalElements, totalPages);
    }
}
