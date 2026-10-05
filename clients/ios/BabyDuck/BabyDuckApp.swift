// 小黄鸭乐园 iOS 客户端:SwiftUI + WKWebView 壳 + 原生中文语音桥。
import SwiftUI
import WebKit
import AVFoundation

final class SpeakBridge: NSObject, WKScriptMessageHandler {
    private let synth = AVSpeechSynthesizer()

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "speak",
              let body = message.body as? String,
              let data = body.data(using: .utf8),
              let obj = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
              let text = obj["t"] as? String else { return }
        synth.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        if let rate = obj["r"] as? Double { utterance.rate = Float(min(1.0, max(0.1, rate * 0.55))) }
        if let pitch = obj["p"] as? Double { utterance.pitchMultiplier = Float(min(2.0, max(0.5, pitch))) }
        synth.speak(utterance)
    }
}

struct DuckWebView: UIViewRepresentable {
    func makeCoordinator() -> SpeakBridge { SpeakBridge() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.mediaTypesRequiringUserActionForPlayback = []
        let injection = WKUserScript(
            source: "window.__nativeSpeak = function(j){ try{ window.webkit.messageHandlers.speak.postMessage(j); }catch(e){} };",
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true)
        config.userContentController.addUserScript(injection)
        config.userContentController.add(context.coordinator, name: "speak")

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 0.557, green: 0.847, blue: 0.973, alpha: 1)
        webView.scrollView.isScrollEnabled = false
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

@main
struct BabyDuckApp: App {
    var body: some Scene {
        WindowGroup {
            DuckWebView()
                .ignoresSafeArea()
        }
    }
}
