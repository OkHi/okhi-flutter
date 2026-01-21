package io.okhi.flutter.okhi_flutter

import android.app.Activity
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import io.okhi.android.OkHi
import io.okhi.android.collect.OkCollect
import io.okhi.android.collect.OkCollectConfig
import io.okhi.android.collect.OkCollectStyle
import io.okhi.android.core.model.OkHiLocation
import io.okhi.android.collect.models.OkHiSuccessResponse
import io.okhi.android.core.enums.LocationAccuracyLevel
import io.okhi.android.core.interfaces.OkHiAddressVerificationCallback
import io.okhi.android.core.model.OkHiAuth
import io.okhi.android.core.model.OkHiException
import io.okhi.android.core.model.OkHiUser
import kotlin.collections.ArrayList
import kotlin.collections.HashMap

class OkhiFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel : MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity
    private lateinit var auth: OkHiAuth
    private lateinit var collect: OkCollect
    private lateinit var okHiUser: OkHiUser
    private lateinit var cachedLocation: Location
    private var isFetchingLocation = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "okhi_flutter")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        try {
            activity = binding.activity
        } catch (e: Exception) {
            // handle exception
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // Handle configuration changes (e.g. rotation)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        // Re-setup after configuration change
    }

    override fun onDetachedFromActivity() {
        // Clean up activity references
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> handleGetPlatformVersion(call, result)
            "isLocationServicesEnabled" -> handleIsLocationServicesEnabled(call, result)
            "isLocationPermissionGranted" -> handleIsLocationPermissionGranted(call, result)
            "isBackgroundLocationPermissionGranted" -> handleIsBackgroundLocationPermissionGranted(
                call,
                result
            )

            "isGooglePlayServicesAvailable" -> handleIsGooglePlayServicesAvailable(call, result)
            "isNotificationsEnabled" -> handleIsNotificationsEnabled(call, result)
            "requestLocationPermission" -> handleRequestLocationPermission(call, result)
            "requestBackgroundLocationPermission" -> handleRequestBackgroundLocationPermission(
                call,
                result
            )

            "requestEnableLocationServices" -> handleRequestEnableLocationServices(call, result)
            "requestEnableNotifications" -> handleRequestNotificationPermission(call, result)
            "getAppIdentifier" -> handleGetAppIdentifier(call, result)
            "getAppVersion" -> handleGetAppVersion(call, result)
            "initialize" -> handleInitialize(call, result)
            "startDigitalAddressVerification" -> handleStartDigitalVerification(call, result)
            "startPhysicalAddressVerification" -> handleStartPhysicalVerification(call, result)
            "startDigitalAndPhysicalAddressVerification" -> handleStartDigitalAndPhysicalVerification(call, result)
            "createAddress" -> handleCreateAddress(call, result)
            "startSavedAddressVerification" -> handleStartSavedVerification(call, result)
            "canOpenProtectedApps" -> handleCanOpenProtectedApps(call, result)
            "openProtectedApps" -> handleOpenProtectedApps(call, result)
            "retrieveDeviceInfo" -> handleRetrieveDeviceInfo(call, result)
            "fetchLocationPermissionStatus" -> handleFetchLocationPermissionStatus(call, result)
            "openAppSettings" -> handleOpenAppSettings(call, result)
            "getLocationAccuracyLevel" -> handleGetLocationAccuracyLevel(call, result)
            else -> result.notImplemented()
        }
    }

    private fun handleCreateAddress(
        call: MethodCall,
        result: Result
    ) {
        var isReplied = false
        OkHi.createAddress(
            activity,
            collect,
            object : OkHiAddressVerificationCallback() {
                override fun onSuccess(response: OkHiSuccessResponse) {
                    Log.e("Yay!" ,"createAddress onSuccess $isReplied")

                    if (isReplied) return
                    isReplied = true
                    result.success(response.location.id.toString())
                }

                override fun onClose() {
                    Log.e("Yay!" ,"createAddress onClose $isReplied")
                    if (isReplied) return
                    isReplied = true
                    result.success("user_closed")
                }

                override fun onError(e: OkHiException) {
                    Log.e("Yay!" ,"createAddress onError $isReplied")
                    if (isReplied) return
                    isReplied = true
                    result.error(e.code, e.message, null)
                }
            })
    }

    private fun handleStartSavedVerification(
        call: MethodCall,
        result: Result
    ) {
        var isReplied = false
        val locationId: String? = call.argument("locationId")
        val collectInstance = OkCollect(
            location = OkHiLocation(locationId)
        )

        OkHi.startAddressVerification(
            activity,
            collectInstance,
            object : OkHiAddressVerificationCallback() {
                override fun onSuccess(response: OkHiSuccessResponse) {
                    if (isReplied) return
                    isReplied = true
                    result.success(response.location.id.toString())
                }

                override fun onClose() {
                    if (isReplied) return
                    isReplied = true
                    result.success("user_closed")
                }

                override fun onError(e: OkHiException) {
                    if (isReplied) return
                    isReplied = true
                    result.error(e.code, e.message, null)
                }
            })
    }

    private fun handleStartDigitalAndPhysicalVerification(
        call: MethodCall,
        result: Result
    ) {
        var isReplied = false
        OkHi.startDigitalAndPhysicalAddressVerification(
            activity,
            collect,
            object : OkHiAddressVerificationCallback() {
                override fun onSuccess(response: OkHiSuccessResponse) {
                    if (isReplied) return
                    isReplied = true
                    result.success(response.location.id.toString())
                }

                override fun onClose() {
                    if (isReplied) return
                    isReplied = true
                    result.success("user_closed")
                }

                override fun onError(e: OkHiException) {
                    if (isReplied) return
                    isReplied = true
                    result.error(e.code, e.message, null)
                }
            })
    }

    private fun handleStartPhysicalVerification(
        call: MethodCall,
        result: Result
    ) {
        var isReplied = false
        OkHi.startPhysicalAddressVerification(
            activity,
            collect,
            object : OkHiAddressVerificationCallback() {
                override fun onSuccess(response: OkHiSuccessResponse) {
                    if (isReplied) return
                    isReplied = true
                    result.success(response.location.id.toString())
                }

                override fun onClose() {
                    if (isReplied) return
                    isReplied = true
                    result.success("user_closed")
                }

                override fun onError(e: OkHiException) {
                    if (isReplied) return
                    isReplied = true
                    result.error(e.code, e.message, null)
                }
            })
    }

    private fun handleStartDigitalVerification(
        call: MethodCall,
        result: Result
    ) {
        var isReplied = false
        OkHi.startDigitalAddressVerification(
            activity,
            collect,
            object : OkHiAddressVerificationCallback() {
                override fun onSuccess(response: OkHiSuccessResponse) {
                    if (isReplied) return
                    isReplied = true
                    result.success(response.location.id.toString())
                }

                override fun onClose() {
                    if (isReplied) return
                    isReplied = true
                    result.success("user_closed")
                }

                override fun onError(e: OkHiException) {
                    if (isReplied) return
                    isReplied = true
                    result.error(e.code, e.message, null)
                }
            })
    }

    private fun handleGetLocationAccuracyLevel(call: MethodCall, result: Result) {
        val level: LocationAccuracyLevel = OkHi.getLocationAccuracyLevel(context)
        result.success(level.toString())
    }

    private fun handleGetPlatformVersion(call: MethodCall, result: Result) {
        result.success("${android.os.Build.VERSION.SDK_INT}")
    }

    private fun handleIsNotificationsEnabled(call: MethodCall, result: Result) {
        result.success(OkHi.isPostNotificationPermissionGranted(context))
    }

    private fun handleIsLocationServicesEnabled(call: MethodCall, result: Result) {
        result.success(OkHi.isLocationServicesEnabled(context))
    }

    private fun handleIsLocationPermissionGranted(call: MethodCall, result: Result) {
        result.success(OkHi.isFineLocationPermissionGranted(context))
    }

    private fun handleIsBackgroundLocationPermissionGranted(call: MethodCall, result: Result) {
        result.success(OkHi.isBackgroundLocationPermissionGranted(context))
    }

    private fun handleIsGooglePlayServicesAvailable(call: MethodCall, result: Result) {
        result.success(OkHi.isPlayServicesAvailable(context))
    }

    private fun handleGetAppIdentifier(call: MethodCall, result: Result) {
        result.success(context.getPackageName())
    }

    private fun handleGetAppVersion(call: MethodCall, result: Result) {
        try {
            val versionName: String? =
                context.getPackageManager().getPackageInfo(context.getPackageName(), 0).versionName
            result.success(versionName)
        } catch (e: Exception) {
            result.success("-1")
        }
    }

    private fun handleRequestLocationPermission(call: MethodCall, result: Result) {
        try {
            OkHi.requestLocationPermission(context){
                result.success(it)
            }

        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun handleRequestBackgroundLocationPermission(call: MethodCall, result: Result) {
        try {
            OkHi.requestBackgroundLocationPermission(context){
                result.success(it)
            }
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun handleRequestEnableLocationServices(call: MethodCall, result: Result) {
        try {
            OkHi.requestEnableLocationServices(context){
                result.success(it)
            }
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun handleRequestNotificationPermission(call: MethodCall, result: Result) {
        try {
            OkHi.requestPostNotificationPermissions(context){
                result.success(it)
            }
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun handleInitialize(call: MethodCall, result: Result) {
        try {
            val branchId: String? = call.argument("branchId")
            val clientKey: String? = call.argument("clientKey")
            val mode: String? = call.argument("environment")
            if (branchId == null || clientKey == null || mode == null) {
                result.error("unauthorized", "invalid initialization credentials provided", null)
            } else {

                val style = OkCollectStyle("#263238", "OkHi", "https://cdn.okhi.co/icon.png")
                val config = OkCollectConfig(true, true, false, true)

                collect = OkCollect(style, config)
                auth = OkHiAuth(branchId, clientKey, mode)

                val phone: String? = call.argument("phoneNumber")
                val userId: String? = call.argument("userId")
                val userEmail: String? = call.argument("email")
                val userFirstName: String? = call.argument("firstName")
                val userLastName: String? = call.argument("lastName")
                val token: String? = call.argument("token")
                val appUserId: String? = call.argument("appUserId")

                okHiUser = OkHiUser(
                    firstName = userFirstName ?: "",
                    lastName = userLastName ?: "",
                    phone = phone ?: "",
                    email = userEmail ?: "",
                    appUserId = appUserId,
                    okhiUserId = userId,
                    token = token
                )
                OkHi.login(context, auth, okHiUser) { locationIds ->
                    // TODO: handle login
                }

                result.success(true)
            }
        } catch (e: Exception) {
            result.error("unknown_error", "initialization failed", e)
        }
    }

    private fun handleCanOpenProtectedApps(call: MethodCall, result: Result) {
        result.success(OkHi.canOpenProtectedApps(context));
    }

    private fun handleOpenProtectedApps(call: MethodCall, result: Result) {
        try {
            OkHi.openProtectedApps(context)
            result.success(true)
        } catch (e: OkHiException) {
            result.error(e.code, e.message, e)
        }
    }

    private fun handleRetrieveDeviceInfo(call: MethodCall, result: Result) {
        val deviceInfo: HashMap<String, Any> = HashMap<String, Any>()
        deviceInfo.put("manufacturer", Build.MANUFACTURER)
        deviceInfo.put("model", Build.MODEL)
        deviceInfo.put("osVersion", Build.VERSION.RELEASE)
        deviceInfo.put("platform", "android")
        result.success(deviceInfo)
    }

    private fun handleFetchLocationPermissionStatus(call: MethodCall, result: Result) {
        if (OkHi.isBackgroundLocationPermissionGranted(activity)) {
            result.success("always")
        } else if (OkHi.isFineLocationPermissionGranted(activity)) {
            result.success("whenInUse")
        } else {
            result.success("denied")
        }
    }

    private fun handleOpenAppSettings(call: MethodCall, result: Result) {
        val intent: Intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        val uri: Uri? = Uri.fromParts("package", activity.getPackageName(), null)
        intent.setData(uri)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        activity.startActivity(intent)
        result.success(true)
    }
}
