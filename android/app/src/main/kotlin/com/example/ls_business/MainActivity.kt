package com.infinitylab.ls_business

import android.content.ContentResolver
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.FileOutputStream
import java.io.InputStream

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.ls_business.share"
    private lateinit var methodChannel: MethodChannel

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        methodChannel.setMethodCallHandler { call, result ->
            if (call.method == "copyFileFromUri") {
                val uriString = call.argument<String>("uri")
                val destPath = call.argument<String>("destinationPath")
                if (uriString != null && destPath != null) {
                    val isFileSaved = copyFileFromUri(Uri.parse(uriString), destPath)
                    if (isFileSaved) {
                        result.success(destPath)
                    } else {
                        result.error("FILE_SAVE_ERROR", "Error copying the content URI", null)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "Arguments are null", null)
                }
            } else if (call.method == "copyVideoFromUri") {
                val uriString = call.argument<String>("uri")
                val destPath = call.argument<String>("destinationPath")
                if (uriString != null && destPath != null) {
                    val isFileSaved = copyVideoFromUri(Uri.parse(uriString), destPath)
                    if (isFileSaved) {
                        result.success(destPath)
                    } else {
                        result.error("FILE_SAVE_ERROR", "Error copying the video URI", null)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "Arguments are null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun copyFileFromUri(uri: Uri, destinationPath: String): Boolean {
        return try {
            val resolver: ContentResolver = applicationContext.contentResolver
            resolver.openInputStream(uri)?.use { inputStream ->
                FileOutputStream(destinationPath).use { outputStream ->
                    inputStream.copyTo(outputStream)
                }
            }
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun copyVideoFromUri(uri: Uri, destinationPath: String): Boolean {
        return try {
            val resolver: ContentResolver = applicationContext.contentResolver
            resolver.openInputStream(uri)?.use { inputStream ->
                FileOutputStream(destinationPath).use { outputStream ->
                    inputStream.copyTo(outputStream)
                }
            }
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
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
                val type = it.type
                val mediaUris: ArrayList<Uri>? = if (it.action == Intent.ACTION_SEND) {
                    it.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)?.let { uri -> arrayListOf(uri) }
                } else {
                    it.getParcelableArrayListExtra(Intent.EXTRA_STREAM)
                }

                if (!mediaUris.isNullOrEmpty()) {
                    val uri = mediaUris.first()

                    if (type != null && type.startsWith("video/")) {
                        methodChannel.invokeMethod("shareVideo", listOf(uri.toString()))
                    } else if (type != null && type.startsWith("image/")) {
                        val imagePaths = mediaUris.map { it.toString() }
                        methodChannel.invokeMethod("shareImage", imagePaths)
                    }
                }
            }
        }
    }
}
