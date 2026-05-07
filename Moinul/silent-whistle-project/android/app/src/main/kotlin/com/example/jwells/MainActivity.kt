package com.john.jwells

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "jwells/google_auth",
        ).setMethodCallHandler { call, result ->
            if (call.method == "getDefaultWebClientId") {
                val resourceId = resources.getIdentifier(
                    "default_web_client_id",
                    "string",
                    packageName,
                )

                val clientId = if (resourceId != 0) getString(resourceId) else ""
                result.success(clientId)
            } else {
                result.notImplemented()
            }
        }
    }
}
