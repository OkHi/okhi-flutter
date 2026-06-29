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
import android.os.Handler
import android.os.Looper

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink

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
import org.json.JSONArray
import org.json.JSONObject

class OkhiFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel : MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity
    private lateinit var auth: OkHiAuth
    private lateinit var collect: OkCollect
    private lateinit var okHiUser: OkHiUser
    private lateinit var cachedLocation: Location
    private var eventSink: EventChannel.EventSink? = null
    private var isFetchingLocation = false
    private var activeOperationToken: Int = 0

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "okhi_flutter")
        channel.setMethodCallHandler(this)
        setUpEventChannel(flutterPluginBinding)
    }

    fun setUpEventChannel(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        EventChannel(flutterPluginBinding.binaryMessenger, "okhi_flutter_events").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
    }

    private fun sendEvent(data: Any) {
        Handler(Looper.getMainLooper()).post {
            if (eventSink != null){
                eventSink?.success(data.toString())
            }
        }
    }

    private fun closeStream() {
        Handler(Looper.getMainLooper()).post {
            eventSink?.endOfStream()
            eventSink = null
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        closeStream()
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

            "startDigitalAddressVerification" -> {
                val locationId: String? = call.argument("locationId")
                if(locationId != null) {
                    handleStartSavedVerification(locationId, result)
                } else {
                    handleStartDigitalVerification(call, result)
                }
            }
            "startPhysicalAddressVerification" -> handleStartPhysicalVerification(call, result)
            "startDigitalAndPhysicalAddressVerification" -> handleStartDigitalAndPhysicalVerification(call, result)
            "createAddress" -> handleCreateAddress(call, result)

            "canOpenProtectedApps" -> handleCanOpenProtectedApps(call, result)
            "openProtectedApps" -> handleOpenProtectedApps(call, result)
            "retrieveDeviceInfo" -> handleRetrieveDeviceInfo(call, result)
            "fetchLocationPermissionStatus" -> handleFetchLocationPermissionStatus(call, result)
            "openAppSettings" -> handleOpenAppSettings(call, result)
            "getLocationAccuracyLevel" -> handleGetLocationAccuracyLevel(call, result)
            "logout" -> handleLogout(call, result)
            else -> result.notImplemented()
        }
    }

    private fun handleCreateAddress(
        call: MethodCall,
        result: Result
    ) {
        val token = activeOperationToken
        OkHi.createAddress(
            activity,
            collect,
            object : OkHiAddressVerificationCallback() {
                override fun onSuccess(response: OkHiSuccessResponse) {
                    if (activeOperationToken != token) return
                    val eventObject = getSuccessEventObject("createAddress", response)
                    sendEvent(eventObject)
                }

                override fun onClose() {
                    if (activeOperationToken != token) return
                    val eventObject= JSONObject()
                    eventObject.put("methodCall","createAddress")
                    eventObject.put("type","closed")
                    sendEvent(eventObject)
                }

                override fun onError(e: OkHiException) {
                    if (activeOperationToken != token) return
                    val eventObject= JSONObject()
                    eventObject.put("methodCall","createAddress")
                    eventObject.put("type","error")
                    eventObject.put("code",e.code)
                    eventObject.put("message",e.message)
                    sendEvent(eventObject)
                }
            })
        result.success(null)
    }

    private fun handleStartDigitalAndPhysicalVerification(
        call: MethodCall,
        result: Result
    ) {
        val token = activeOperationToken
        OkHi.startDigitalAndPhysicalAddressVerification(
            activity,
            collect,
            object : OkHiAddressVerificationCallback() {
                override fun onSuccess(response: OkHiSuccessResponse) {
                    if (activeOperationToken != token) return
                    val eventObject = getSuccessEventObject("startDigitalAndPhysicalAddressVerification", response)
                    sendEvent(eventObject)
                }

                override fun onClose() {
                    if (activeOperationToken != token) return
                    val eventObject= JSONObject()
                    eventObject.put("methodCall","startDigitalAndPhysicalAddressVerification")
                    eventObject.put("type","closed")
                    sendEvent(eventObject)
                }

                override fun onError(e: OkHiException) {
                    if (activeOperationToken != token) return
                    val eventObject= JSONObject()
                    eventObject.put("methodCall","startDigitalAndPhysicalAddressVerification")
                    eventObject.put("type","error")
                    eventObject.put("code",e.code)
                    eventObject.put("message",e.message)
                    sendEvent(eventObject)
                }
            })
        result.success(null)
    }

    private fun handleStartPhysicalVerification(
        call: MethodCall,
        result: Result
    ) {
        val token = activeOperationToken
        OkHi.startPhysicalAddressVerification(
            activity,
            collect,
            object : OkHiAddressVerificationCallback() {
                override fun onSuccess(response: OkHiSuccessResponse) {
                    if (activeOperationToken != token) return
                    val eventObject = getSuccessEventObject("startPhysicalAddressVerification", response)
                    sendEvent(eventObject)
                }

                override fun onClose() {
                    if (activeOperationToken != token) return
                    val eventObject= JSONObject()
                    eventObject.put("methodCall","startPhysicalAddressVerification")
                    eventObject.put("type","closed")
                    sendEvent(eventObject)
                }

                override fun onError(e: OkHiException) {
                    if (activeOperationToken != token) return
                    val eventObject= JSONObject()
                    eventObject.put("methodCall","startPhysicalAddressVerification")
                    eventObject.put("type","error")
                    eventObject.put("code",e.code)
                    eventObject.put("message",e.message)
                    sendEvent(eventObject)
                }
            })
        result.success(null)
    }

    private fun handleStartDigitalVerification(
        call: MethodCall,
        result: Result
    ) {
        val token = activeOperationToken
        OkHi.startDigitalAddressVerification(
            activity,
            collect,
            object : OkHiAddressVerificationCallback() {
                override fun onSuccess(response: OkHiSuccessResponse) {
                    if (activeOperationToken != token) return
                    val eventObject = getSuccessEventObject("startDigitalAddressVerification", response)
                    sendEvent(eventObject)
                }

                override fun onClose() {
                    if (activeOperationToken != token) return
                    val eventObject= JSONObject()
                    eventObject.put("methodCall","startDigitalAddressVerification")
                    eventObject.put("type","closed")
                    sendEvent(eventObject)
                }

                override fun onError(e: OkHiException) {
                    if (activeOperationToken != token) return
                    val eventObject= JSONObject()
                    eventObject.put("methodCall","startDigitalAddressVerification")
                    eventObject.put("type","error")
                    eventObject.put("code",e.code)
                    eventObject.put("message",e.message)
                    sendEvent(eventObject)
                }
            }
        )
        result.success(null)
    }

    private fun handleStartSavedVerification(
        locationId: String,
        result: Result
    ) {
        val token = activeOperationToken
        val collectInstance = OkCollect(collect.style, collect.config, OkHiLocation(locationId))
        OkHi.startAddressVerification(
            activity,
            collectInstance,
            object : OkHiAddressVerificationCallback() {
                override fun onSuccess(response: OkHiSuccessResponse) {
                    if (activeOperationToken != token) return
                    val eventObject = getSuccessEventObject("startSavedAddressVerification", response)
                    sendEvent(eventObject)
                }

                override fun onClose() {
                    if (activeOperationToken != token) return
                    val eventObject= JSONObject()
                    eventObject.put("methodCall","startSavedAddressVerification")
                    eventObject.put("type","closed")
                    sendEvent(eventObject)
                }

                override fun onError(e: OkHiException) {
                    if (activeOperationToken != token) return
                    val eventObject= JSONObject()
                    eventObject.put("methodCall","startSavedAddressVerification")
                    eventObject.put("type","error")
                    eventObject.put("code",e.code)
                    eventObject.put("message",e.message)
                    sendEvent(eventObject)
                }

            }
        )
        result.success(null)
    }

    private fun getSuccessEventObject(methodCall: String, response: OkHiSuccessResponse): JSONObject {

        val eventObject= JSONObject()
        eventObject.put("methodCall",methodCall)
        eventObject.put("type","success")

        val userObject= JSONObject()
        userObject.put("email",response.user.email)
        userObject.put("firstName",response.user.firstName)
        userObject.put("lastName",response.user.lastName)
        userObject.put("id",response.user.okhiUserId)
        userObject.put("phone",response.user.phone)
        userObject.put("appUserId",response.user.appUserId)
        userObject.put("token",response.user.token)
        eventObject.put("user",userObject)

        val locationObject= JSONObject()
        locationObject.put("id",response.location.id)
        locationObject.put("lat",response.location.lat)
        locationObject.put("lng",response.location.lng)
        locationObject.put("city",response.location.city)
        locationObject.put("country",response.location.country)
        locationObject.put("directions",response.location.directions)
        locationObject.put("displayTitle",response.location.displayTitle)
        locationObject.put("otherInformation",response.location.otherInformation)
        locationObject.put("photoUrl",response.location.photoUrl)
        locationObject.put("placeId",response.location.placeId)
        locationObject.put("plusCode",response.location.plusCode)
        locationObject.put("propertyName",response.location.propertyName)
        locationObject.put("propertyNumber",response.location.propertyNumber)
        locationObject.put("state",response.location.state)
        locationObject.put("streetName",response.location.streetName)
        locationObject.put("streetViewPanoId",response.location.streetViewPanoId)
        locationObject.put("streetViewPanoUrl",response.location.streetViewPanoUrl)
        locationObject.put("subtitle",response.location.subtitle)
        locationObject.put("title",response.location.title)
        locationObject.put("url",response.location.url)
        locationObject.put("userId",response.location.userId)
        locationObject.put("neighborhood",response.location.neighborhood)
        locationObject.put("countryCode",response.location.countryCode)
        locationObject.put("usageTypes", JSONArray(response.location.usageTypes ?: emptyArray<String>()))
        locationObject.put("ward",response.location.ward)
        locationObject.put("formattedAddress",response.location.formattedAddress)
        locationObject.put("postCode",response.location.postCode)
        locationObject.put("lga",response.location.lga)
        locationObject.put("lgaCode",response.location.lgaCode)
        locationObject.put("unit",response.location.unit)
        locationObject.put("gpsAccuracy",response.location.gpsAccuracy)
        locationObject.put("businessName",response.location.businessName)
        locationObject.put("type",response.location.type)
        locationObject.put("district",response.location.district)
        locationObject.put("addressLine",response.location.addressLine)

        eventObject.put("location",locationObject)
        return eventObject
    }

    private fun handleLogout(call: MethodCall, result: Result) {
        OkHi.logout(context) { list ->
            OkHiMainThreadResult(result).success(list)
        }
    }

    private fun handleGetLocationAccuracyLevel(call: MethodCall, result: Result) {
        val level: LocationAccuracyLevel = OkHi.getLocationAccuracyLevel(context)
        OkHiMainThreadResult(result).success(level.toString())
    }

    private fun handleGetPlatformVersion(call: MethodCall, result: Result) {
        OkHiMainThreadResult(result).success("${android.os.Build.VERSION.SDK_INT}")
    }

    private fun handleIsNotificationsEnabled(call: MethodCall, result: Result) {
        OkHiMainThreadResult(result).success(OkHi.isPostNotificationPermissionGranted(context))
    }

    private fun handleIsLocationServicesEnabled(call: MethodCall, result: Result) {
        OkHiMainThreadResult(result).success(OkHi.isLocationServicesEnabled(context))
    }

    private fun handleIsLocationPermissionGranted(call: MethodCall, result: Result) {
        OkHiMainThreadResult(result).success(OkHi.isFineLocationPermissionGranted(context))
    }

    private fun handleIsBackgroundLocationPermissionGranted(call: MethodCall, result: Result) {
        OkHiMainThreadResult(result).success(OkHi.isBackgroundLocationPermissionGranted(context))
    }

    private fun handleIsGooglePlayServicesAvailable(call: MethodCall, result: Result) {
        OkHiMainThreadResult(result).success(OkHi.isPlayServicesAvailable(context))
    }

    private fun handleGetAppIdentifier(call: MethodCall, result: Result) {
        OkHiMainThreadResult(result).success(context.getPackageName())
    }

    private fun handleGetAppVersion(call: MethodCall, result: Result) {
        try {
            val versionName: String? =
                context.getPackageManager().getPackageInfo(context.getPackageName(), 0).versionName
            OkHiMainThreadResult(result).success(versionName)
        } catch (e: Exception) {
            OkHiMainThreadResult(result).success("-1")
        }
    }

    private fun handleRequestLocationPermission(call: MethodCall, result: Result) {
        try {
            OkHi.requestLocationPermission(context){
                OkHiMainThreadResult(result).success(it)
            }

        } catch (e: Exception) {
            OkHiMainThreadResult(result).success(false)
        }
    }

    private fun handleRequestBackgroundLocationPermission(call: MethodCall, result: Result) {
        try {
            OkHi.requestBackgroundLocationPermission(context){
                OkHiMainThreadResult(result).success(it)
            }
        } catch (e: Exception) {
            OkHiMainThreadResult(result).success(false)
        }
    }

    private fun handleRequestEnableLocationServices(call: MethodCall, result: Result) {
        try {
            OkHi.requestEnableLocationServices(context){
                OkHiMainThreadResult(result).success(it)
            }
        } catch (e: Exception) {
            OkHiMainThreadResult(result).success(false)
        }
    }

    private fun handleRequestNotificationPermission(call: MethodCall, result: Result) {
        try {
            OkHi.requestPostNotificationPermissions(context){
                OkHiMainThreadResult(result).success(it)
            }
        } catch (e: Exception) {
            OkHiMainThreadResult(result).success(false)
        }
    }

    private fun handleInitialize(call: MethodCall, result: Result) {
        try {
            val branchId: String? = call.argument("branchId")
            val clientKey: String? = call.argument("clientKey")
            val mode: String? = call.argument("environment")
            val locationManagerConfiguration: Map<String, Any>? = call.argument("locationManagerConfiguration")

            if (branchId == null || clientKey == null || mode == null) {
                result.error("unauthorized", "invalid initialization credentials provided", null)
            } else {

                var style = OkCollectStyle("#263238", "OkHi", "https://cdn.okhi.co/icon.png")
                var config = OkCollectConfig(true, true, false, true)

                if(locationManagerConfiguration != null) {
                    style = OkCollectStyle(
                        (locationManagerConfiguration["color"] as? String) ?: "#263238",
                        (locationManagerConfiguration["appName"] as? String) ?: "OkHi",
                        (locationManagerConfiguration["logoUrl"] as? String) ?: "https://cdn.okhi.co/icon.png"
                    )
                    config = OkCollectConfig(
                        (locationManagerConfiguration["withStreetView"] as? Boolean) ?: true,
                        (locationManagerConfiguration["withHomeAddressType"] as? Boolean) ?: true,
                        (locationManagerConfiguration["withWorkAddressType"] as? Boolean) ?: false,
                        (locationManagerConfiguration["withAppBar"] as? Boolean) ?: true
                    )
                }

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
                activeOperationToken++

                OkHi.login(context, auth, okHiUser) { locationIds ->
                    // todo: handle login
                }

                OkHiMainThreadResult(result).success(true)
            }
        } catch (e: Exception) {
            OkHiMainThreadResult(result).error("unknown_error", "initialization failed", e)
        }
    }

    private fun handleCanOpenProtectedApps(call: MethodCall, result: Result) {
        OkHiMainThreadResult(result).success(OkHi.canOpenProtectedApps(context));
    }

    private fun handleOpenProtectedApps(call: MethodCall, result: Result) {
        try {
            OkHi.openProtectedApps(context)
            OkHiMainThreadResult(result).success(true)
        } catch (e: OkHiException) {
            OkHiMainThreadResult(result).error(e.code, e.message, e)
        }
    }

    private fun handleRetrieveDeviceInfo(call: MethodCall, result: Result) {
        val deviceInfo: HashMap<String, Any> = HashMap<String, Any>()
        deviceInfo.put("manufacturer", Build.MANUFACTURER)
        deviceInfo.put("model", Build.MODEL)
        deviceInfo.put("osVersion", Build.VERSION.RELEASE)
        deviceInfo.put("platform", "android")
        OkHiMainThreadResult(result).success(deviceInfo)
    }

    private fun handleFetchLocationPermissionStatus(call: MethodCall, result: Result) {
        if (OkHi.isBackgroundLocationPermissionGranted(activity)) {
            OkHiMainThreadResult(result).success("always")
        } else if (OkHi.isFineLocationPermissionGranted(activity)) {
            OkHiMainThreadResult(result).success("whenInUse")
        } else {
            OkHiMainThreadResult(result).success("denied")
        }
    }

    private fun handleOpenAppSettings(call: MethodCall, result: Result) {
        val intent: Intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        val uri: Uri? = Uri.fromParts("package", activity.getPackageName(), null)
        intent.setData(uri)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        activity.startActivity(intent)
        OkHiMainThreadResult(result).success(true)
    }
}
