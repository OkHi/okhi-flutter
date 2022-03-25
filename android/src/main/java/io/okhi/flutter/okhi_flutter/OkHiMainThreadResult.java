package io.okhi.flutter.okhi_flutter;

import android.os.Handler;
import android.os.Looper;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.MethodChannel;

public class OkHiMainThreadResult implements MethodChannel.Result {
  private MethodChannel.Result result;
  private Handler handler;

  OkHiMainThreadResult(MethodChannel.Result result) {
    this.result = result;
    handler = new Handler(Looper.getMainLooper());
  }

  @Override
  public void success(@Nullable Object value) {
    handler.post(
      new Runnable() {
        @Override
        public void run() {
          result.success(value);
        }
      });
  }

  @Override
  public void error(
    final String errorCode, final String errorMessage, final Object errorDetails) {
    handler.post(
      new Runnable() {
        @Override
        public void run() {
          result.error(errorCode, errorMessage, errorDetails);
        }
      });
  }

  @Override
  public void notImplemented() {
    handler.post(
      new Runnable() {
        @Override
        public void run() {
          result.notImplemented();
        }
      });
  }
}
