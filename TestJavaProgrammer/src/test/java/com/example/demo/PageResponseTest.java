package com.example.demo;

import com.example.demo.model.PageResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Unit tests for PageResponse.
 * Tests pagination logic and edge cases.
 */
@DisplayName("PageResponse Unit Tests")
class PageResponseTest {

    @Nested
    @DisplayName("Basic Pagination Tests")
    class BasicPaginationTests {

        @Test
        @DisplayName("Should create page response with correct metadata for first page")
        void shouldCreatePageResponseWithCorrectMetadata() {
            // Arrange
            List<String> items = List.of("a", "b", "c", "d", "e");

            // Act
            PageResponse<String> response = PageResponse.of(items, 0, 2);

            // Assert
            assertThat(response.content()).containsExactly("a", "b");
            assertThat(response.page()).isEqualTo(0);
            assertThat(response.size()).isEqualTo(2);
            assertThat(response.totalElements()).isEqualTo(5);
            assertThat(response.totalPages()).isEqualTo(3);
        }

        @Test
        @DisplayName("Should return correct content for second page")
        void shouldReturnSecondPage() {
            // Arrange
            List<String> items = List.of("a", "b", "c", "d", "e");

            // Act
            PageResponse<String> response = PageResponse.of(items, 1, 2);

            // Assert
            assertThat(response.content()).containsExactly("c", "d");
            assertThat(response.page()).isEqualTo(1);
        }

        @Test
        @DisplayName("Should return partial content for last page")
        void shouldReturnLastPageWithPartialContent() {
            // Arrange
            List<String> items = List.of("a", "b", "c", "d", "e");

            // Act
            PageResponse<String> response = PageResponse.of(items, 2, 2);

            // Assert
            assertThat(response.content()).containsExactly("e");
            assertThat(response.page()).isEqualTo(2);
            assertThat(response.totalPages()).isEqualTo(3);
        }
    }

    @Nested
    @DisplayName("Boundary Condition Tests")
    class BoundaryConditionTests {

        @Test
        @DisplayName("Should return empty content when page number exceeds available data")
        void shouldReturnEmptyContentWhenPageExceedsData() {
            // Arrange
            List<String> items = List.of("a", "b", "c");

            // Act
            PageResponse<String> response = PageResponse.of(items, 10, 2);

            // Assert
            assertThat(response.content()).isEmpty();
            assertThat(response.page()).isEqualTo(10);
            assertThat(response.totalElements()).isEqualTo(3);
            assertThat(response.totalPages()).isEqualTo(2);
        }

        @Test
        @DisplayName("Should handle empty source list gracefully")
        void shouldHandleEmptyList() {
            // Arrange
            List<String> items = List.of();

            // Act
            PageResponse<String> response = PageResponse.of(items, 0, 10);

            // Assert
            assertThat(response.content()).isEmpty();
            assertThat(response.page()).isEqualTo(0);
            assertThat(response.size()).isEqualTo(10);
            assertThat(response.totalElements()).isEqualTo(0);
            assertThat(response.totalPages()).isEqualTo(0);
        }

        @Test
        @DisplayName("Should return single page when page size exceeds total elements")
        void shouldReturnSinglePageWhenSizeExceedsTotalElements() {
            // Arrange
            List<String> items = List.of("a", "b", "c");

            // Act
            PageResponse<String> response = PageResponse.of(items, 0, 100);

            // Assert
            assertThat(response.content()).containsExactly("a", "b", "c");
            assertThat(response.totalPages()).isEqualTo(1);
        }

        @Test
        @DisplayName("Should handle single element per page correctly")
        void shouldHandleSingleElementPerPage() {
            // Arrange
            List<String> items = List.of("a", "b", "c");

            // Act
            PageResponse<String> page0 = PageResponse.of(items, 0, 1);
            PageResponse<String> page1 = PageResponse.of(items, 1, 1);
            PageResponse<String> page2 = PageResponse.of(items, 2, 1);

            // Assert
            assertThat(page0.content()).containsExactly("a");
            assertThat(page1.content()).containsExactly("b");
            assertThat(page2.content()).containsExactly("c");
            assertThat(page0.totalPages()).isEqualTo(3);
        }
    }

    @Nested
    @DisplayName("Total Pages Calculation Tests")
    class TotalPagesCalculationTests {

        @Test
        @DisplayName("Should calculate total pages correctly for various scenarios")
        void shouldCalculateTotalPagesCorrectly() {
            // Test exact division (4 items / 2 per page = 2 pages)
            PageResponse<String> exactResponse = PageResponse.of(List.of("a", "b", "c", "d"), 0, 2);
            assertThat(exactResponse.totalPages()).isEqualTo(2);

            // Test with remainder (5 items / 2 per page = 3 pages)
            PageResponse<String> remainderResponse = PageResponse.of(List.of("a", "b", "c", "d", "e"), 0, 2);
            assertThat(remainderResponse.totalPages()).isEqualTo(3);

            // Test single element (1 item / 10 per page = 1 page)
            PageResponse<String> singleResponse = PageResponse.of(List.of("a"), 0, 10);
            assertThat(singleResponse.totalPages()).isEqualTo(1);
        }
    }
}
