package jp.hikari.hikari

import android.app.WallpaperManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "hikari/system")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getDeviceInfo" -> result.success(
                        mapOf(
                            "platform" to "Android",
                            "version" to (Build.VERSION.RELEASE ?: "—"),
                            "model" to "${Build.MANUFACTURER} ${Build.MODEL}".trim(),
                            "wallpaperSupported" to true,
                        ),
                    )

                    "applyWallpaper" -> {
                        val path = call.arguments as? String
                        if (path.isNullOrBlank()) {
                            result.error("bad_args", "Путь к обоям обязателен", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val file = File(path)
                            if (!file.exists()) {
                                result.error("wallpaper_failed", "Файл обоев не найден", null)
                                return@setMethodCallHandler
                            }
                            val manager = WallpaperManager.getInstance(applicationContext)
                            val which = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK
                            } else {
                                WallpaperManager.FLAG_SYSTEM
                            }
                            file.inputStream().use { stream ->
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                    manager.setStream(stream, null, true, which)
                                } else {
                                    manager.setStream(stream)
                                }
                            }
                            result.success(true)
                        } catch (error: Exception) {
                            result.error("wallpaper_failed", error.message, null)
                        }
                    }

                    "applyTheme" -> {
                        // Тему внутри приложения применяет Flutter; системный
                        // ночной режим Android требует привилегий, поэтому
                        // честно сообщаем, что изменение системное недоступно.
                        val dark = call.argument<Boolean>("dark") ?: false
                        result.success(
                            mapOf(
                                "applied" to true,
                                "system" to false,
                                "dark" to dark,
                            ),
                        )
                    }

                    "resetSystemTheme" -> result.success(true)
                    else -> result.notImplemented()
                }
            }
    }
}
