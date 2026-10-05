package com.babyduck.game

import android.annotation.SuppressLint
import android.app.Activity
import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.view.View
import android.webkit.JavascriptInterface
import android.webkit.WebView
import android.webkit.WebViewClient
import org.json.JSONObject
import java.util.Locale

class MainActivity : Activity() {
    private var tts: TextToSpeech? = null

    @Volatile
    private var ttsReady = false

    // 供网页 speak() 调用的原生中文语音桥,比 WebView 内置 speechSynthesis 可靠。
    private inner class SpeakBridge {
        @JavascriptInterface
        fun speak(json: String) {
            val obj = try { JSONObject(json) } catch (_: Exception) { return }
            val text = obj.optString("t")
            if (text.isEmpty()) return
            val engine = tts ?: return
            if (!ttsReady) return
            val rate = (obj.optDouble("r", 0.95) * 0.55).toFloat().coerceIn(0.1f, 1.0f)
            val pitch = obj.optDouble("p", 1.3).toFloat().coerceIn(0.5f, 2.0f)
            engine.setSpeechRate(rate)
            engine.setPitch(pitch)
            engine.speak(text, TextToSpeech.QUEUE_FLUSH, null, "duck")
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        tts = TextToSpeech(this) { status ->
            if (status == TextToSpeech.SUCCESS) {
                tts?.language = Locale.SIMPLIFIED_CHINESE
                ttsReady = true
            }
        }
        val webView = WebView(this)
        webView.settings.javaScriptEnabled = true
        webView.settings.mediaPlaybackRequiresUserGesture = false
        webView.setBackgroundColor(0xFF8ED8F8.toInt())
        webView.addJavascriptInterface(SpeakBridge(), "AndroidSpeak")
        webView.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView, url: String) {
                view.evaluateJavascript(
                    "window.__nativeSpeak=function(j){ try{ AndroidSpeak.speak(j);}catch(e){} };", null)
            }
        }
        setContentView(webView)
        hideSystemBars()
        webView.loadUrl("file:///android_asset/index.html")
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) hideSystemBars()
    }

    @Suppress("DEPRECATION")
    private fun hideSystemBars() {
        window.decorView.systemUiVisibility =
            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
            View.SYSTEM_UI_FLAG_FULLSCREEN or
            View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
            View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
            View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
            View.SYSTEM_UI_FLAG_LAYOUT_STABLE
    }

    override fun onDestroy() {
        tts?.shutdown()
        super.onDestroy()
    }
}
