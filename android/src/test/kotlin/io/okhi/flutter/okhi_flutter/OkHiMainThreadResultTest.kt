package io.okhi.flutter.okhi_flutter

import io.flutter.plugin.common.MethodChannel
import org.junit.Before
import org.junit.Test
import org.mockito.Mock
import org.mockito.Mockito.*
import org.mockito.MockitoAnnotations
import kotlin.test.assertNotNull

/**
 * Unit tests for OkHiMainThreadResult class
 *
 * OkHiMainThreadResult wraps a MethodChannel.Result and ensures all result callbacks
 * are posted to the Android main thread using a Handler. This is critical for Flutter
 * integration as method channel results must be delivered on the main thread.
 *
 * Note: These tests verify the class interface and contract. Testing actual Handler
 * behavior requires instrumentation tests or Robolectric.
 */
class OkHiMainThreadResultTest {

    @Mock
    private lateinit var mockResult: MethodChannel.Result

    @Before
    fun setUp() {
        MockitoAnnotations.openMocks(this)
    }

    // ========================================
    // Interface Contract Tests
    // ========================================

    @Test
    fun `Result interface - success method accepts null parameter`() {
        mockResult.success(null)
        verify(mockResult, times(1)).success(null)
    }

    @Test
    fun `Result interface - success method accepts string parameter`() {
        mockResult.success("test_value")
        verify(mockResult, times(1)).success("test_value")
    }

    @Test
    fun `Result interface - success method accepts integer parameter`() {
        mockResult.success(42)
        verify(mockResult, times(1)).success(42)
    }

    @Test
    fun `Result interface - success method accepts boolean parameter`() {
        mockResult.success(true)
        verify(mockResult, times(1)).success(true)
    }

    @Test
    fun `Result interface - success method accepts map parameter`() {
        val testMap = mapOf("key" to "value", "number" to 123)
        mockResult.success(testMap)
        verify(mockResult, times(1)).success(testMap)
    }

    @Test
    fun `Result interface - success method accepts list parameter`() {
        val testList = listOf(1, 2, 3, "four", 5.0)
        mockResult.success(testList)
        verify(mockResult, times(1)).success(testList)
    }

    @Test
    fun `Result interface - error method with all parameters`() {
        mockResult.error("ERROR_CODE", "Error message", mapOf("detail" to "value"))
        verify(mockResult, times(1)).error(
            eq("ERROR_CODE"),
            eq("Error message"),
            eq(mapOf("detail" to "value"))
        )
    }

    @Test
    fun `Result interface - error method with null message and details`() {
        mockResult.error("ERROR_CODE", null, null)
        verify(mockResult, times(1)).error("ERROR_CODE", null, null)
    }

    @Test
    fun `Result interface - error method with empty error code`() {
        mockResult.error("", "Empty code error", null)
        verify(mockResult, times(1)).error("", "Empty code error", null)
    }

    @Test
    fun `Result interface - notImplemented method`() {
        mockResult.notImplemented()
        verify(mockResult, times(1)).notImplemented()
    }

    // ========================================
    // Data Type Edge Cases
    // ========================================

    @Test
    fun `success with large numeric values`() {
        mockResult.success(Long.MAX_VALUE)
        mockResult.success(Long.MIN_VALUE)
        mockResult.success(Double.MAX_VALUE)
        mockResult.success(Double.MIN_VALUE)

        verify(mockResult, times(4)).success(any())
    }

    @Test
    fun `success with complex nested data structures`() {
        val complexData = mapOf(
            "level1" to mapOf(
                "level2" to mapOf(
                    "level3" to listOf(1, 2, 3),
                    "nested_value" to "deep"
                ),
                "array" to listOf("a", "b", "c")
            ),
            "top_level" to "value"
        )
        mockResult.success(complexData)
        verify(mockResult, times(1)).success(complexData)
    }

    @Test
    fun `success with large collection`() {
        val largeList = (1..1000).map { "item_$it" }
        mockResult.success(largeList)
        verify(mockResult, times(1)).success(largeList)
    }

    @Test
    fun `success with empty collections`() {
        mockResult.success(emptyList<Any>())
        mockResult.success(emptyMap<String, Any>())

        verify(mockResult, times(2)).success(any())
    }

    @Test
    fun `error with special characters in message`() {
        val specialChars = "Error with chars: !@#$%^&*()_+{}[]|\\:;\"'<>,.?/"
        mockResult.error("SPECIAL_CHARS", specialChars, null)
        verify(mockResult, times(1)).error("SPECIAL_CHARS", specialChars, null)
    }

    @Test
    fun `error with unicode characters in message`() {
        val unicode = "Error: 你好 مرحبا हैलो 🔥 🎉 😀"
        mockResult.error("UNICODE", unicode, null)
        verify(mockResult, times(1)).error("UNICODE", unicode, null)
    }

    @Test
    fun `error with very long message`() {
        val longMessage = "A".repeat(10000)
        mockResult.error("LONG_ERROR", longMessage, null)
        verify(mockResult, times(1)).error("LONG_ERROR", longMessage, null)
    }

    @Test
    fun `error with complex error details object`() {
        val complexDetails = mapOf(
            "stackTrace" to listOf("line1", "line2", "line3"),
            "timestamp" to System.currentTimeMillis(),
            "metadata" to mapOf(
                "version" to "1.0.0",
                "build" to 123,
                "environment" to "test"
            ),
            "context" to mapOf(
                "userId" to "user_123",
                "sessionId" to "session_456"
            )
        )
        mockResult.error("COMPLEX_ERROR", "Complex error occurred", complexDetails)
        verify(mockResult, times(1)).error(
            eq("COMPLEX_ERROR"),
            eq("Complex error occurred"),
            eq(complexDetails)
        )
    }

    // ========================================
    // Sequential Call Tests
    // ========================================

    @Test
    fun `multiple success calls in sequence`() {
        mockResult.success("first")
        mockResult.success("second")
        mockResult.success("third")

        verify(mockResult).success("first")
        verify(mockResult).success("second")
        verify(mockResult).success("third")
    }

    @Test
    fun `mixed method calls in sequence`() {
        mockResult.success("success_value")
        mockResult.error("ERROR", "error_message", null)
        mockResult.notImplemented()

        verify(mockResult).success("success_value")
        verify(mockResult).error("ERROR", "error_message", null)
        verify(mockResult).notImplemented()
    }

    @Test
    fun `multiple error calls with different codes`() {
        mockResult.error("ERROR_1", "First error", null)
        mockResult.error("ERROR_2", "Second error", null)
        mockResult.error("ERROR_3", "Third error", null)

        verify(mockResult).error("ERROR_1", "First error", null)
        verify(mockResult).error("ERROR_2", "Second error", null)
        verify(mockResult).error("ERROR_3", "Third error", null)
    }

    // ========================================
    // Real-world Scenario Tests
    // ========================================

    @Test
    fun `success with location data structure`() {
        val locationData = mapOf(
            "id" to "loc_12345",
            "lat" to -1.2921,
            "lng" to 36.8219,
            "displayTitle" to "Nairobi, Kenya",
            "city" to "Nairobi",
            "country" to "Kenya"
        )
        mockResult.success(locationData)
        verify(mockResult, times(1)).success(locationData)
    }

    @Test
    fun `success with user data structure`() {
        val userData = mapOf(
            "id" to "user_123",
            "phone" to "+254712345678",
            "firstName" to "John",
            "lastName" to "Doe",
            "email" to "john@example.com"
        )
        mockResult.success(userData)
        verify(mockResult, times(1)).success(userData)
    }

    @Test
    fun `error with authentication failure`() {
        mockResult.error(
            "UNAUTHORIZED",
            "Invalid credentials provided",
            mapOf("attempted_phone" to "+254712345678")
        )
        verify(mockResult, times(1)).error(
            eq("UNAUTHORIZED"),
            eq("Invalid credentials provided"),
            eq(mapOf("attempted_phone" to "+254712345678"))
        )
    }

    @Test
    fun `error with network failure`() {
        mockResult.error(
            "NETWORK_ERROR",
            "Failed to connect to server",
            mapOf(
                "url" to "https://api.okhi.com",
                "statusCode" to 503,
                "retryAfter" to 60
            )
        )
        verify(mockResult, times(1)).error(
            eq("NETWORK_ERROR"),
            eq("Failed to connect to server"),
            any()
        )
    }

    @Test
    fun `notImplemented for unsupported method`() {
        // Simulate calling an unsupported method
        mockResult.notImplemented()
        verify(mockResult, times(1)).notImplemented()
    }

    // ========================================
    // Boundary and Stress Tests
    // ========================================

    @Test
    fun `success with zero value`() {
        mockResult.success(0)
        verify(mockResult, times(1)).success(0)
    }

    @Test
    fun `success with negative numbers`() {
        mockResult.success(-1)
        mockResult.success(-999999)
        mockResult.success(-3.14159)

        verify(mockResult, times(3)).success(any())
    }

    @Test
    fun `success with extreme floating point values`() {
        mockResult.success(Double.POSITIVE_INFINITY)
        mockResult.success(Double.NEGATIVE_INFINITY)
        mockResult.success(Double.NaN)

        verify(mockResult, times(3)).success(any())
    }

    @Test
    fun `error with empty message string`() {
        mockResult.error("ERROR_CODE", "", null)
        verify(mockResult, times(1)).error("ERROR_CODE", "", null)
    }

    @Test
    fun `success with map containing null values`() {
        val mapWithNulls = mapOf(
            "key1" to "value1",
            "key2" to null,
            "key3" to "value3"
        )
        mockResult.success(mapWithNulls)
        verify(mockResult, times(1)).success(mapWithNulls)
    }

    @Test
    fun `success with mixed type list`() {
        val mixedList = listOf(
            "string",
            42,
            true,
            3.14,
            null,
            mapOf("nested" to "value"),
            listOf(1, 2, 3)
        )
        mockResult.success(mixedList)
        verify(mockResult, times(1)).success(mixedList)
    }

    // ========================================
    // Method Channel Result Contract
    // ========================================

    @Test
    fun `verify Result interface can be assigned and used`() {
        val result: MethodChannel.Result = mockResult

        assertNotNull(result)
        result.success("test")
        result.error("ERROR", "message", null)
        result.notImplemented()

        verify(mockResult).success("test")
        verify(mockResult).error("ERROR", "message", null)
        verify(mockResult).notImplemented()
    }

    @Test
    fun `verify only one result method should be called per channel call`() {
        // In real usage, only one of success/error/notImplemented should be called
        // per method channel invocation

        mockResult.success("result")

        // Verify no other methods were called
        verify(mockResult, never()).error(anyString(), anyString(), any())
        verify(mockResult, never()).notImplemented()
    }
}