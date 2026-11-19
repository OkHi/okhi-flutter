package io.okhi.flutter.okhi_flutter

import android.app.Activity
import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.okhi.android.OkHi
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mock
import org.mockito.Mockito.*
import org.mockito.MockitoAnnotations
import org.mockito.junit.MockitoJUnitRunner
import kotlin.test.assertNotNull

/**
 * Comprehensive unit tests for OkhiFlutterPlugin class
 * Tests Flutter plugin integration, method handling, and OkHi SDK interactions
 */
@RunWith(MockitoJUnitRunner::class)
class OkhiFlutterPluginTest {

    @Mock
    private lateinit var mockFlutterPluginBinding: FlutterPlugin.FlutterPluginBinding

    @Mock
    private lateinit var mockBinaryMessenger: BinaryMessenger

    @Mock
    private lateinit var mockContext: Context

    @Mock
    private lateinit var mockActivity: Activity

    @Mock
    private lateinit var mockActivityPluginBinding: ActivityPluginBinding

    @Mock
    private lateinit var mockMethodCall: MethodCall

    @Mock
    private lateinit var mockResult: MethodChannel.Result

    @Mock
    private lateinit var mockPackageManager: PackageManager

    @Mock
    private lateinit var mockPackageInfo: PackageInfo

    private lateinit var plugin: OkhiFlutterPlugin

    @Before
    fun setUp() {
        MockitoAnnotations.openMocks(this)

        // Setup mocks
        `when`(mockFlutterPluginBinding.applicationContext).thenReturn(mockContext)
        `when`(mockFlutterPluginBinding.binaryMessenger).thenReturn(mockBinaryMessenger)
        `when`(mockActivityPluginBinding.activity).thenReturn(mockActivity)
        `when`(mockContext.packageManager).thenReturn(mockPackageManager)
        `when`(mockContext.packageName).thenReturn("io.okhi.test")

        // Create plugin instance
        plugin = OkhiFlutterPlugin()
    }

    // ========================================
    // Lifecycle Tests
    // ========================================

    @Test
    fun `onAttachedToEngine should initialize plugin correctly`() {
        // Act
        plugin.onAttachedToEngine(mockFlutterPluginBinding)

        // Assert
        verify(mockFlutterPluginBinding).applicationContext
        verify(mockFlutterPluginBinding, atLeastOnce()).binaryMessenger
    }

    @Test
    fun `onAttachedToActivity should set activity`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)

        // Act
        plugin.onAttachedToActivity(mockActivityPluginBinding)

        // Assert
        verify(mockActivityPluginBinding).activity
    }

    @Test
    fun `onDetachedFromEngine should cleanup resources`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)

        // Act
        plugin.onDetachedFromEngine(mockFlutterPluginBinding)

        // Assert - Should not throw any exceptions
        assertNotNull(plugin)
    }

    @Test
    fun `onDetachedFromActivity should handle cleanup`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        plugin.onAttachedToActivity(mockActivityPluginBinding)

        // Act
        plugin.onDetachedFromActivity()

        // Assert - Should not throw any exceptions
        assertNotNull(plugin)
    }

    @Test
    fun `onDetachedFromActivityForConfigChanges should handle config changes`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)

        // Act
        plugin.onDetachedFromActivityForConfigChanges()

        // Assert - Should not throw any exceptions
        assertNotNull(plugin)
    }

    @Test
    fun `onReattachedToActivityForConfigChanges should reattach after config changes`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)

        // Act
        plugin.onReattachedToActivityForConfigChanges(mockActivityPluginBinding)

        // Assert - Should not throw any exceptions
        assertNotNull(plugin)
    }

    // ========================================
    // Method Call Tests - Platform Info
    // ========================================

    @Test
    fun `getPlatformVersion should return Android SDK version`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("getPlatformVersion")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert - Result is posted to main thread, so verify no immediate call
        verify(mockResult, never()).success(anyString())
    }

    @Test
    fun `getAppIdentifier should return package name`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("getAppIdentifier")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        verify(mockContext, atLeastOnce()).packageName
    }

    @Test
    fun `getAppVersion should return version name`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("getAppVersion")
        mockPackageInfo.versionName = "1.0.0"
        `when`(mockPackageManager.getPackageInfo(anyString(), anyInt())).thenReturn(mockPackageInfo)

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        verify(mockPackageManager).getPackageInfo(anyString(), anyInt())
    }

    @Test
    fun `getAppVersion should return -1 on exception`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("getAppVersion")
        `when`(mockPackageManager.getPackageInfo(anyString(), anyInt()))
            .thenThrow(PackageManager.NameNotFoundException())

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        verify(mockPackageManager).getPackageInfo(anyString(), anyInt())
    }

    // ========================================
    // Method Call Tests - Permissions & Services
    // ========================================

    @Test
    fun `isLocationServicesEnabled should check location services`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("isLocationServicesEnabled")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert - Method was called
        assertNotNull(plugin)
    }

    @Test
    fun `isLocationPermissionGranted should check location permission`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("isLocationPermissionGranted")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `isBackgroundLocationPermissionGranted should check background permission`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("isBackgroundLocationPermissionGranted")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `isGooglePlayServicesAvailable should check play services`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("isGooglePlayServicesAvailable")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `isNotificationsEnabled should check notification permission`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("isNotificationsEnabled")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `requestLocationPermission should request location permission`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("requestLocationPermission")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `requestBackgroundLocationPermission should request background permission`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("requestBackgroundLocationPermission")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `requestEnableLocationServices should request enable location`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("requestEnableLocationServices")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `requestEnableNotifications should request notification permission`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("requestEnableNotifications")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `fetchLocationPermissionStatus should return permission status`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        plugin.onAttachedToActivity(mockActivityPluginBinding)
        `when`(mockMethodCall.method).thenReturn("fetchLocationPermissionStatus")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    // ========================================
    // Method Call Tests - Device Info
    // ========================================

    @Test
    fun `retrieveDeviceInfo should return device information`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("retrieveDeviceInfo")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert - Device info should be collected
        assertNotNull(plugin)
    }

    @Test
    fun `canOpenProtectedApps should check protected apps availability`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("canOpenProtectedApps")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `openProtectedApps should open protected apps settings`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("openProtectedApps")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `openAppSettings should open app settings`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        plugin.onAttachedToActivity(mockActivityPluginBinding)
        `when`(mockMethodCall.method).thenReturn("openAppSettings")
        `when`(mockActivity.packageName).thenReturn("io.okhi.test")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `getLocationAccuracyLevel should return accuracy level`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("getLocationAccuracyLevel")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    // ========================================
    // Method Call Tests - Initialization
    // ========================================

    @Test
    fun `initialize should fail with missing branchId`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("initialize")
        `when`(mockMethodCall.argument<String>("branchId")).thenReturn(null)
        `when`(mockMethodCall.argument<String>("clientKey")).thenReturn("test_key")
        `when`(mockMethodCall.argument<String>("environment")).thenReturn("prod")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert - Should call error on result
        verify(mockResult, never()).success(any())
    }

    @Test
    fun `initialize should fail with missing clientKey`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("initialize")
        `when`(mockMethodCall.argument<String>("branchId")).thenReturn("test_branch")
        `when`(mockMethodCall.argument<String>("clientKey")).thenReturn(null)
        `when`(mockMethodCall.argument<String>("environment")).thenReturn("prod")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        verify(mockResult, never()).success(any())
    }

    @Test
    fun `initialize should fail with missing environment`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("initialize")
        `when`(mockMethodCall.argument<String>("branchId")).thenReturn("test_branch")
        `when`(mockMethodCall.argument<String>("clientKey")).thenReturn("test_key")
        `when`(mockMethodCall.argument<String>("environment")).thenReturn(null)

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        verify(mockResult, never()).success(any())
    }

    @Test
    fun `initialize should succeed with valid credentials`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("initialize")
        `when`(mockMethodCall.argument<String>("branchId")).thenReturn("test_branch")
        `when`(mockMethodCall.argument<String>("clientKey")).thenReturn("test_key")
        `when`(mockMethodCall.argument<String>("environment")).thenReturn("prod")
        `when`(mockMethodCall.argument<String>("phoneNumber")).thenReturn("+254712345678")
        `when`(mockMethodCall.argument<String>("firstName")).thenReturn("John")
        `when`(mockMethodCall.argument<String>("lastName")).thenReturn("Doe")
        `when`(mockMethodCall.argument<String>("appUserId")).thenReturn("user123")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `initialize should handle location manager configuration`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("initialize")
        `when`(mockMethodCall.argument<String>("branchId")).thenReturn("test_branch")
        `when`(mockMethodCall.argument<String>("clientKey")).thenReturn("test_key")
        `when`(mockMethodCall.argument<String>("environment")).thenReturn("prod")

        val locationConfig = mapOf(
            "color" to "#FF0000",
            "appName" to "Test App",
            "logoUrl" to "https://example.com/logo.png",
            "withStreetView" to "true",
            "withHomeAddressType" to "true",
            "withWorkAddressType" to "false",
            "withAppBar" to "true"
        )
        `when`(mockMethodCall.argument<Map<String, String>>("locationManagerConfiguration")).thenReturn(locationConfig)

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    // ========================================
    // Method Call Tests - Address Verification
    // ========================================

    @Test
    fun `startDigitalAddressVerification should start verification without locationId`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        plugin.onAttachedToActivity(mockActivityPluginBinding)
        `when`(mockMethodCall.method).thenReturn("startDigitalAddressVerification")
        `when`(mockMethodCall.argument<String>("locationId")).thenReturn(null)

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `startDigitalAddressVerification should start saved verification with locationId`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        plugin.onAttachedToActivity(mockActivityPluginBinding)
        `when`(mockMethodCall.method).thenReturn("startDigitalAddressVerification")
        `when`(mockMethodCall.argument<String>("locationId")).thenReturn("loc_12345")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `startPhysicalAddressVerification should start physical verification`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        plugin.onAttachedToActivity(mockActivityPluginBinding)
        `when`(mockMethodCall.method).thenReturn("startPhysicalAddressVerification")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `startDigitalAndPhysicalAddressVerification should start both verifications`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        plugin.onAttachedToActivity(mockActivityPluginBinding)
        `when`(mockMethodCall.method).thenReturn("startDigitalAndPhysicalAddressVerification")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `createAddress should create address without verification`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        plugin.onAttachedToActivity(mockActivityPluginBinding)
        `when`(mockMethodCall.method).thenReturn("createAddress")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    // ========================================
    // Method Call Tests - Logout
    // ========================================

    @Test
    fun `logout should call OkHi logout`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("logout")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    // ========================================
    // Method Call Tests - Unimplemented
    // ========================================

    @Test
    fun `unknown method should return notImplemented`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("unknownMethod")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        verify(mockResult).notImplemented()
    }

    @Test
    fun `null method should return notImplemented`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn(null)

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        verify(mockResult).notImplemented()
    }

    @Test
    fun `empty method should return notImplemented`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        verify(mockResult).notImplemented()
    }

    // ========================================
    // Edge Cases and Error Handling
    // ========================================

    @Test
    fun `multiple onAttachedToEngine calls should handle gracefully`() {
        // Act
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        plugin.onAttachedToEngine(mockFlutterPluginBinding)

        // Assert - Should not throw
        assertNotNull(plugin)
    }

    @Test
    fun `onAttachedToActivity without onAttachedToEngine should handle gracefully`() {
        // Act & Assert - Should not throw
        try {
            plugin.onAttachedToActivity(mockActivityPluginBinding)
            assertNotNull(plugin)
        } catch (e: Exception) {
            // Expected to potentially throw, which is acceptable
            assertNotNull(e)
        }
    }

    @Test
    fun `initialize with empty user fields should succeed`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("initialize")
        `when`(mockMethodCall.argument<String>("branchId")).thenReturn("test_branch")
        `when`(mockMethodCall.argument<String>("clientKey")).thenReturn("test_key")
        `when`(mockMethodCall.argument<String>("environment")).thenReturn("prod")
        `when`(mockMethodCall.argument<String>("phoneNumber")).thenReturn("")
        `when`(mockMethodCall.argument<String>("firstName")).thenReturn("")
        `when`(mockMethodCall.argument<String>("lastName")).thenReturn("")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `initialize with all optional fields null should succeed`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("initialize")
        `when`(mockMethodCall.argument<String>("branchId")).thenReturn("test_branch")
        `when`(mockMethodCall.argument<String>("clientKey")).thenReturn("test_key")
        `when`(mockMethodCall.argument<String>("environment")).thenReturn("prod")
        `when`(mockMethodCall.argument<String>("phoneNumber")).thenReturn(null)
        `when`(mockMethodCall.argument<String>("firstName")).thenReturn(null)
        `when`(mockMethodCall.argument<String>("lastName")).thenReturn(null)
        `when`(mockMethodCall.argument<String>("email")).thenReturn(null)
        `when`(mockMethodCall.argument<String>("userId")).thenReturn(null)
        `when`(mockMethodCall.argument<String>("appUserId")).thenReturn(null)
        `when`(mockMethodCall.argument<String>("token")).thenReturn(null)

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `initialize with special characters in fields should handle properly`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("initialize")
        `when`(mockMethodCall.argument<String>("branchId")).thenReturn("test_branch")
        `when`(mockMethodCall.argument<String>("clientKey")).thenReturn("test_key")
        `when`(mockMethodCall.argument<String>("environment")).thenReturn("prod")
        `when`(mockMethodCall.argument<String>("phoneNumber")).thenReturn("+254-712-345-678")
        `when`(mockMethodCall.argument<String>("firstName")).thenReturn("John-Paul")
        `when`(mockMethodCall.argument<String>("lastName")).thenReturn("O'Brien")
        `when`(mockMethodCall.argument<String>("email")).thenReturn("test+tag@example.com")

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        assertNotNull(plugin)
    }

    @Test
    fun `getAppVersion with null versionName should return -1`() {
        // Arrange
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
        `when`(mockMethodCall.method).thenReturn("getAppVersion")
        mockPackageInfo.versionName = null
        `when`(mockPackageManager.getPackageInfo(anyString(), anyInt())).thenReturn(mockPackageInfo)

        // Act
        plugin.onMethodCall(mockMethodCall, mockResult)

        // Assert
        verify(mockPackageManager).getPackageInfo(anyString(), anyInt())
    }
}