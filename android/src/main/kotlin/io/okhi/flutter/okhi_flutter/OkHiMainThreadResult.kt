package io.okhi.flutter.okhi_flutter;

import android.os.Handler;
import android.os.Looper;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.MethodChannel;

class OkHiMainThreadResult(private val result: MethodChannel.Result) : MethodChannel.Result {
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun success(@Nullable value: Any?) {
        mainHandler.post {
            this.result.success(value)
        }
    }

    override fun error(
        errorCode: String,
        @Nullable errorMessage: String?,
        @Nullable errorDetails: Any?
    ) {
        mainHandler.post {
            this.result.error(errorCode, errorMessage, errorDetails)
        }
    }

    override fun notImplemented() {
        mainHandler.post {
            this.result.notImplemented()
        }
    }
}
