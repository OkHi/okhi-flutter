package io.okhi.flutter.okhi_flutter;

import android.app.Activity;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;

import androidx.annotation.NonNull;

import org.json.JSONObject;
import java.util.ArrayList;
import java.util.Arrays;

import java.util.HashMap;
import java.util.Map;
import android.util.Log;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.okhi.android_core.OkHi;
import io.okhi.android_core.interfaces.OkHiRequestHandler;
import io.okhi.android_core.models.OkCollectSuccessResponse;
import io.okhi.android_core.models.OkHiAppContext;
import io.okhi.android_core.models.OkHiAuth;
import io.okhi.android_core.models.OkHiException;
import io.okhi.android_core.models.OkHiLocation;
import io.okhi.android_core.models.OkHiLocationService;
import io.okhi.android_core.models.OkHiPermissionService;
import io.okhi.android_core.models.OkHiUser;
import io.okhi.android_core.models.OkPreference;
import io.okhi.android_okverify.OkVerify;
import io.okhi.android_okverify.interfaces.OkVerifyCallback;
import io.okhi.android_okverify.models.OkHiNotification;

/** OkhiFlutterPlugin */
public class OkhiFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private OkHi okHi;
  private Context context;
  private final static String TAG = "OkHi";
  private OkVerify okVerify;
  private OkHiAuth auth;
  private Activity activity;

  private final PluginRegistry.ActivityResultListener activityResultListener = new PluginRegistry.ActivityResultListener() {
    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
      if (okHi != null) {
        okHi.onActivityResult(requestCode, resultCode, data);
      }
      return false;
    }
  };
  private final PluginRegistry.RequestPermissionsResultListener requestPermissionsResultListener = new PluginRegistry.RequestPermissionsResultListener() {
    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
      if (okHi != null) {
        okHi.onRequestPermissionsResult(requestCode, permissions, grantResults);
      }
      return false;
    }
  };
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "okhi_flutter");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "getPlatformVersion":
        handleGetPlatformVersion(call, result);
        break;
      case "isLocationServicesEnabled":
        handleIsLocationServicesEnabled(call, result);
        break;
      case "isLocationPermissionGranted":
        handleIsLocationPermissionGranted(call, result);
        break;
      case "isBackgroundLocationPermissionGranted":
        handleIsBackgroundLocationPermissionGranted(call, result);
        break;
      case "isGooglePlayServicesAvailable":
        handleIsGooglePlayServicesAvailable(call, result);
        break;
      case "requestLocationPermission":
        handleRequestLocationPermission(call, result);
        break;
      case "requestBackgroundLocationPermission":
        handleRequestBackgroundLocationPermission(call, result);
        break;
      case "requestEnableLocationServices":
        handleRequestEnableLocationServices(call, result);
        break;
      case "requestEnableGooglePlayServices":
        handleRequestEnableGooglePlayServices(call, result);
        break;
      case "getAppIdentifier":
        handleGetAppIdentifier(call, result);
        break;
      case "getAppVersion":
        handleGetAppVersion(call, result);
        break;
      case "initialize":
        handleInitialize(call, result);
        break;
      case "startVerification":
        handleStartVerification(call, result);
        break;
      case "stopVerification":
        handleStopVerification(call, result);
        break;
      case "isForegroundServiceRunning":
        handleIsForegroundServiceRunning(call, result);
        break;
      case "startForegroundService":
        handleStartForegroundService(call, result);
        break;
      case "stopForegroundService":
        handleStopForegroundService(call, result);
        break;
      case "getCurrentLocation":
        handleGetCurrentLocation(call, result);
        break;
      case "canOpenProtectedApps":
        handleCanOpenProtectedApps(call, result);
        break;
      case "openProtectedApps":
        handleOpenProtectedApps(call, result);
        break;
      case "setItem":
        handleSetItem(call, result);
        break;
      case "retrieveDeviceInfo":
        handleRetrieveDeviceInfo(call, result);
        break;
      case "fetchLocationPermissionStatus":
        handleFetchLocationPermissionStatus(call, result);
        break;
      case "fetchRegisteredGeofences":
        handleFetchRegisteredGeofences(call, result);
        break;
      case "openAppSettings":
        handleOpenAppSettings(call, result);
        break;
      case "getLocationAccuracyLevel":
        handleGetLocationAccuracyLevel(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    try {
      okHi = new OkHi(binding.getActivity());
      activity = binding.getActivity();
      binding.addActivityResultListener(activityResultListener);
      binding.addRequestPermissionsResultListener(requestPermissionsResultListener);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }

  private void handleGetLocationAccuracyLevel(MethodCall call, Result result) {
    String level = OkHiLocationService.getLocationAccuracyLevel(activity);
    result.success(level);
  }

  private void handleGetPlatformVersion(MethodCall call, Result result) {
    result.success(android.os.Build.VERSION.SDK_INT + "");
  }

  private void handleIsLocationServicesEnabled(MethodCall call, Result result) {
    result.success(OkHi.isLocationServicesEnabled(context));
  }

  private void handleIsLocationPermissionGranted(MethodCall call, Result result) {
    result.success(OkHi.isLocationPermissionGranted(context));
  }

  private void handleIsBackgroundLocationPermissionGranted(MethodCall call, Result result) {
    result.success(OkHi.isBackgroundLocationPermissionGranted(context));
  }

  private void handleIsGooglePlayServicesAvailable(MethodCall call, Result result) {
    result.success(OkHi.isGooglePlayServicesAvailable(context));
  }

  private void handleGetAppIdentifier(MethodCall call, Result result) {
    result.success(context.getPackageName());
  }

  private void handleGetAppVersion(MethodCall call, Result result) {
    try {
      String versionName = context.getPackageManager().getPackageInfo(context.getPackageName(), 0).versionName;
      result.success(versionName);
    } catch (Exception e) {
      e.printStackTrace();
      result.success("-1");
    }
  }

  private void handleRequestLocationPermission(MethodCall call, final Result result) {
    okHi.requestLocationPermission(new OkHiRequestHandler<Boolean>() {
      @Override
      public void onResult(Boolean permission) {
        result.success(permission);
      }
      @Override
      public void onError(OkHiException exception) {
        result.error(exception.getCode(), exception.getMessage(), exception.getStackTrace());
      }
    });
  }

  private void handleRequestBackgroundLocationPermission(MethodCall call, Result result) {
    okHi.requestBackgroundLocationPermission(new OkHiRequestHandler<Boolean>() {
      @Override
      public void onResult(Boolean permission) {
        result.success(permission);
      }
      @Override
      public void onError(OkHiException exception) {
        result.error(exception.getCode(), exception.getMessage(), exception.getStackTrace());
      }
    });
  }

  private void handleRequestEnableLocationServices(MethodCall call, Result result) {
    okHi.requestEnableLocationServices(new OkHiRequestHandler<Boolean>() {
      @Override
      public void onResult(Boolean service) {
        result.success(service);
      }
      @Override
      public void onError(OkHiException exception) {
        result.error(exception.getCode(), exception.getMessage(), exception.getStackTrace());
      }
    });
  }

  private void handleRequestEnableGooglePlayServices(MethodCall call, Result result) {
    okHi.requestEnableGooglePlayServices(new OkHiRequestHandler<Boolean>() {
      @Override
      public void onResult(Boolean service) {
        result.success(service);
      }
      @Override
      public void onError(OkHiException exception) {
        result.error(exception.getCode(), exception.getMessage(), exception.getStackTrace());
      }
    });
  }

  private void handleInitialize(MethodCall call, Result result) {
    try {
      String branchId = call.argument("branchId");
      String clientKey = call.argument("clientKey");
      String mode = call.argument("environment");
      String developer = call.argument("developer");
      if (branchId == null || clientKey == null || mode == null) {
        result.error("unauthorized", "invalid initialization credentials provided", null);
      } else if (activity == null) {
        result.error("unknown_error", "unable to obtain activity", null);
      } else {
        OkHiAppContext appContext = new OkHiAppContext(context, mode, "flutter", developer == null ? "external" : developer);
        auth = new OkHiAuth(context, branchId, clientKey, appContext);
        okVerify = new OkVerify.Builder(activity, auth).build();
        Map<String, Object> notification = call.<HashMap<String, Object>>argument("notification");
        int importance = Build.VERSION.SDK_INT >= Build.VERSION_CODES.N ? NotificationManager.IMPORTANCE_DEFAULT : 3;
        String title = notification != null && notification.containsKey("title") ? (String) notification.get("title") : "Verification in progress";
        String text = notification != null && notification.containsKey("text") ? (String) notification.get("text") : "Your address is being verified";
        String channelId = notification != null && notification.containsKey("channelId") ? (String) notification.get("channelId") : "okhi";
        String channelName = notification != null && notification.containsKey("channelName") ? (String) notification.get("channelName") : "OkHi";
        String channelDescription = notification != null && notification.containsKey("channelDescription") ? (String) notification.get("channelDescription") : "Address verification alerts";
        OkVerify.init(context, new OkHiNotification(title, text, channelId, channelName, channelDescription, importance));
        result.success(true);
      }
    } catch (Exception e) {
      result.error("unknown_error", "initialization failed", e);
    }
  }

  private void handleStartVerification(MethodCall call, Result result) {
    if (okVerify == null) {
      result.error("unauthorized", "invalid initialization credentials provided", null);
      return;
    }
    String phone = call.argument("phoneNumber");
    String userId = call.argument("userId");
    String token = call.argument("token");
    String locationId = call.argument("locationId");
    Double lat = call.argument("lat");
    Double lon = call.argument("lon");
    Boolean withForegroundService = call.argument("withForegroundService");
    ArrayList<String> usageTypes = call.argument("usageTypes");
    String[] usageTypesList = usageTypes.toArray(new String[0]);

    if (phone == null || locationId == null || lat == null || lon == null) {
      result.error("bad_request", "invalid values provided for address verification", null);
      return;
    }

    OkHiLocation location = new OkHiLocation.Builder(locationId, lat, lon).setUsageTypes(usageTypesList).build();
    OkHiUser user = new OkHiUser.Builder(phone).withOkHiUserId(userId).withToken(token).build();
    OkCollectSuccessResponse response = new OkCollectSuccessResponse(user, location);

    okVerify.start(response, new OkVerifyCallback<String>() {
      @Override
      public void onSuccess(String verificationResult) {
        new OkHiMainThreadResult(result).success(verificationResult);
      }
      @Override
      public void onError(OkHiException e) {
        new OkHiMainThreadResult(result).error(e.getCode(),  e.getMessage(), null);
      }
    });
  }

  private void handleStopVerification(MethodCall call, Result result) {
    if (okVerify == null) {
      result.error("unauthorized", "invalid initialization credentials provided", null);
      return;
    }
    String locationId = call.argument("locationId");
    OkVerify.stop(context, locationId, new OkVerifyCallback<String>() {
      @Override
      public void onSuccess(String verificationResult) {
        new OkHiMainThreadResult(result).success(verificationResult);
      }
      @Override
      public void onError(OkHiException e) {
        new OkHiMainThreadResult(result).error(e.getCode(),  e.getMessage(), null);
      }
    });
  }

  private void handleIsForegroundServiceRunning(MethodCall call, Result result) {
    result.success(OkVerify.isForegroundServiceRunning(context));
  }

  private void handleStartForegroundService(MethodCall call, Result result) {
    try {
      OkVerify.startForegroundService(context);
      result.success(true);
    } catch (OkHiException e) {
      result.error(e.getCode(), e.getMessage(), null);
    }
  }

  private void handleStopForegroundService(MethodCall call, Result result) {
    OkVerify.stopForegroundService(context);
    result.success(true);
  }

  private void handleGetCurrentLocation(MethodCall call, Result result) {
    if (OkHi.isLocationPermissionGranted(context)) {
      OkHiLocationService.getCurrentLocation(context, new OkHiRequestHandler<Location>() {
        @Override
        public void onResult(Location location) {
          if (location != null) {
            HashMap<String, Double> coords = new HashMap<String, Double>();
            coords.put("lat", location.getLatitude());
            coords.put("lng", location.getLongitude());
            coords.put("accuracy", (double) location.getAccuracy());
            result.success(coords);
          } else {
            result.error("unknown_error", "could not retrive coordinates", null);
          }
        }

        @Override
        public void onError(OkHiException exception) {
          result.error(exception.getCode(), exception.getMessage(), null);
        }
      });
    } else {
      result.error("permission_denied", "location permission is not granted", null);
    }
  }

  private void handleCanOpenProtectedApps(MethodCall call, Result result) {
    result.success(OkHiPermissionService.canOpenProtectedApps(context));
  }

  private void handleOpenProtectedApps(MethodCall call, Result result) {
    try {
      OkHiPermissionService.openProtectedAppsSettings(activity, 69);
      result.success(true);
    } catch (OkHiException e) {
      result.error(e.getCode(), e.getMessage(), e);
    }
  }

  private void handleSetItem(MethodCall call, Result result) {
    String key = call.argument("key");
    String value = call.argument("value");
    try {
      OkPreference.setItem(key, value, context);
      result.success(true);
    } catch (OkHiException e) {
      e.printStackTrace();
      result.error(e.getCode(), e.getMessage(), e);
    }
  }

  private void handleRetrieveDeviceInfo(MethodCall call, Result result) {
    HashMap<String, Object> deviceInfo = new HashMap<String, Object>();
    deviceInfo.put("manufacturer", Build.MANUFACTURER);
    deviceInfo.put("model", Build.MODEL);
    deviceInfo.put("osVersion", Build.VERSION.RELEASE);
    deviceInfo.put("platform", "android");
    result.success(deviceInfo);
  }

  private void handleFetchLocationPermissionStatus(MethodCall call, Result result) {
    if (OkHi.isBackgroundLocationPermissionGranted(activity)) {
      result.success("always");
    } else if (OkHi.isLocationPermissionGranted(activity)) {
      result.success("whenInUse");
    } else {
      result.success("denied");
    }
  }

  private void handleFetchRegisteredGeofences(MethodCall call, Result result) {
    result.success(OkVerify.fetchRegisteredGeofences(activity));
  }

  private void handleOpenAppSettings(MethodCall call, Result result) {
    Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
    Uri uri = Uri.fromParts("package", activity.getPackageName(), null);
    intent.setData(uri);
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    activity.startActivity(intent);
    result.success(true);
  }
}
