package com.stardust.mimehealth

import android.app.Activity
import android.app.Application
import android.os.Bundle
import com.intelliprove.webview.IntelliWebViewActivity
import com.intelliprove.webview.IntelliWebViewDelegate
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

class MainActivity : FlutterActivity(), IntelliWebViewDelegate {
    private var webViewChannel: MethodChannel? = null
    private var intelliWebViewActivity: WeakReference<Activity>? = null
    private var lifecycleCallbacks: Application.ActivityLifecycleCallbacks? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Must match the channel name used from Dart / iOS AppDelegate.
        webViewChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.intelliprove/webview",
        )

        webViewChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "openWebview" -> {
                    val args = call.arguments as? Map<*, *>
                    val urlString = args?.get("url") as? String
                    if (urlString.isNullOrBlank()) {
                        result.error("INVALID_ARGS", "Expected { url: String }", null)
                        return@setMethodCallHandler
                    }
                    openWebView(urlString)
                    result.success(null)
                }
                "closeWebview" -> {
                    closeWebView()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        registerIntelliWebViewLifecycleCallbacks()
    }

    override fun onDestroy() {
        lifecycleCallbacks?.let { application.unregisterActivityLifecycleCallbacks(it) }
        lifecycleCallbacks = null
        intelliWebViewActivity = null
        super.onDestroy()
    }

    private fun registerIntelliWebViewLifecycleCallbacks() {
        if (lifecycleCallbacks != null) return
        val callbacks = object : Application.ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
                if (activity is IntelliWebViewActivity) {
                    intelliWebViewActivity = WeakReference(activity)
                }
            }

            override fun onActivityDestroyed(activity: Activity) {
                if (intelliWebViewActivity?.get() === activity) {
                    intelliWebViewActivity = null
                }
            }

            override fun onActivityStarted(activity: Activity) {}
            override fun onActivityResumed(activity: Activity) {}
            override fun onActivityPaused(activity: Activity) {}
            override fun onActivityStopped(activity: Activity) {}
            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
        }
        lifecycleCallbacks = callbacks
        application.registerActivityLifecycleCallbacks(callbacks)
    }

    private fun openWebView(urlString: String) {
        IntelliWebViewActivity.start(this, urlString, this)
    }

    private fun closeWebView() {
        runOnUiThread {
            intelliWebViewActivity?.get()?.finish()
        }
    }

    override fun didReceivePostMessage(postMessage: String) {
        runOnUiThread {
            webViewChannel?.invokeMethod("didReceivePostMessage", postMessage)
        }
    }
}
