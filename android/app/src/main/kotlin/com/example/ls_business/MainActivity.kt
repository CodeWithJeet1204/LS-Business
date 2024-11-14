package com.infinitylab.ls_business

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.ls_business.share"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "openSharePage") {
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        FirebaseApp.initializeApp(/*context=*/ this);
        val firebaseAppCheck = FirebaseAppCheck.getInstance()
        firebaseAppCheck.installAppCheckProviderFactory(
                DebugAppCheckProviderFactory.getInstance())
        super.onCreate(savedInstanceState)
        handleIncomingIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIncomingIntent(intent)
    }

    private fun handleIncomingIntent(intent: Intent?) {
    intent?.let {
        if (it.action == Intent.ACTION_SEND || it.action == Intent.ACTION_SEND_MULTIPLE) {
            val imageUris: ArrayList<Uri>? = if (it.action == Intent.ACTION_SEND) {
                // Handle single Uri, only add if it's non-null
                it.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)?.let { uri -> arrayListOf(uri) }
            } else {
                // Handle multiple Uris
                it.getParcelableArrayListExtra(Intent.EXTRA_STREAM)
            }

            if (!imageUris.isNullOrEmpty()) {
                openSharePage(imageUris)
            }
        }
    }
}



    private fun openSharePage(imageUris: List<Uri>) {
        val imagePaths = imageUris.map { it.toString() }

        val channel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, channelName)
        channel.invokeMethod("openSharePage", imagePaths)
    }
}
