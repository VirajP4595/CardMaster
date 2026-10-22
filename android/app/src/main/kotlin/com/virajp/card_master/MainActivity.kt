package com.virajp.card_master

import android.content.ContentValues
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity is required by local_auth for the biometric prompt.
class MainActivity : FlutterFragmentActivity() {
    companion object {
        const val EXTRA_ROUTE = "cardmaster.route"
        private val ALLOWED_ROUTES = setOf("/quick-add", "/best")
    }

    private var launchChannel: MethodChannel? = null
    private var pendingRoute: String? = null

    /** Only our own shortcuts' routes are accepted. */
    private fun routeFrom(intent: Intent?): String? =
        intent?.getStringExtra(EXTRA_ROUTE)?.takeIf { it in ALLOWED_ROUTES }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        routeFrom(intent)?.let { launchChannel?.invokeMethod("open", it) }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Block screenshots and the recent-apps thumbnail by default (rule R5).
        setSecure(true)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "cardmaster/window")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setSecure" -> {
                        setSecure(call.arguments as? Boolean ?: true)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        pendingRoute = routeFrom(intent)
        launchChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "cardmaster/launch")
            .also { ch ->
                ch.setMethodCallHandler { call, result ->
                    if (call.method == "initialRoute") {
                        result.success(pendingRoute)
                        pendingRoute = null
                    } else {
                        result.notImplemented()
                    }
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "cardmaster/files")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveBackup" -> try {
                        val name = call.argument<String>("name")!!
                        val bytes = call.argument<ByteArray>("bytes")!!
                        val keep = call.argument<Int>("keep") ?: 4
                        result.success(saveBackup(name, bytes, keep))
                    } catch (e: Exception) {
                        result.error("save_failed", e.message, null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Writes an (already encrypted) backup to Downloads/Card Master through
     * MediaStore: no storage permission needed on Android 10+. Keeps the
     * newest [keep] backups this app created. Returns false on older Android.
     */
    private fun saveBackup(name: String, bytes: ByteArray, keep: Int): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return false
        val resolver = contentResolver
        val folder = Environment.DIRECTORY_DOWNLOADS + "/Card Master"
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, name)
            put(MediaStore.MediaColumns.MIME_TYPE, "application/octet-stream")
            put(MediaStore.MediaColumns.RELATIVE_PATH, folder)
        }
        val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
        val uri = resolver.insert(collection, values) ?: return false
        resolver.openOutputStream(uri)?.use { it.write(bytes) } ?: return false

        // Prune older backups that this install created.
        val projection = arrayOf(MediaStore.MediaColumns._ID)
        val selection = MediaStore.MediaColumns.RELATIVE_PATH + "=? AND " +
            MediaStore.MediaColumns.DISPLAY_NAME + " LIKE 'cardmaster-%'"
        resolver.query(
            collection, projection, selection, arrayOf("$folder/"),
            MediaStore.MediaColumns.DATE_ADDED + " DESC"
        )?.use { c ->
            var i = 0
            while (c.moveToNext()) {
                if (i++ >= keep) {
                    val id = c.getLong(0)
                    try {
                        resolver.delete(
                            android.content.ContentUris.withAppendedId(collection, id),
                            null, null
                        )
                    } catch (_: Exception) {
                        // Not ours (e.g. from before a reinstall): leave it.
                    }
                }
            }
        }
        return true
    }

    private fun setSecure(secure: Boolean) {
        if (secure) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }
}
