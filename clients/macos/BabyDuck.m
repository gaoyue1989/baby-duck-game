// 小黄鸭乐园 macOS 客户端:Objective-C + WKWebView 壳 + 原生中文语音桥。
// 编译:见同目录 build.sh(用 clang,不依赖 Swift 工具链)
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <AVFoundation/AVFoundation.h>

// 接收网页 speak() 转发的 JSON,用系统 AVSpeechSynthesizer 朗读中文,
// 比 WKWebView 内置 speechSynthesis 的中文发音更可靠。
@interface SpeakBridge : NSObject <WKScriptMessageHandler>
@property(strong) AVSpeechSynthesizer *synth;
@end

@implementation SpeakBridge
- (instancetype)init {
    if ((self = [super init])) {
        _synth = [[AVSpeechSynthesizer alloc] init];
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController
        didReceiveScriptMessage:(WKScriptMessage *)message {
    if (![message.name isEqualToString:@"speak"]) return;
    if (![message.body isKindOfClass:[NSString class]]) return;
    NSData *data = [(NSString *)message.body dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) return;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![obj isKindOfClass:[NSDictionary class]]) return;
    NSString *text = obj[@"t"];
    if (![text isKindOfClass:[NSString class]] || text.length == 0) return;

    [_synth stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    if (voice) utterance.voice = voice;
    id rate = obj[@"r"], pitch = obj[@"p"];
    if ([rate isKindOfClass:[NSNumber class]]) {
        utterance.rate = (float)MIN(1.0, MAX(0.1, [rate doubleValue] * 0.55));
    }
    if ([pitch isKindOfClass:[NSNumber class]]) {
        utterance.pitchMultiplier = (float)MIN(2.0, MAX(0.5, [pitch doubleValue]));
    }
    [_synth speakUtterance:utterance];
}
@end

@interface AppDelegate : NSObject <NSApplicationDelegate, WKUIDelegate>
@property(strong) NSWindow *window;
@property(strong) WKWebView *webView;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    WKUserContentController *ucc = [[WKUserContentController alloc] init];
    NSString *injection = @"window.__nativeSpeak = function(j){ try{ window.webkit.messageHandlers.speak.postMessage(j); }catch(e){} };";
    [ucc addUserScript:[[WKUserScript alloc] initWithSource:injection
                                               injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                              forMainFrameOnly:YES]];
    [ucc addScriptMessageHandler:[[SpeakBridge alloc] init] name:@"speak"];
    config.userContentController = ucc;

    self.webView = [[WKWebView alloc] initWithFrame:NSZeroRect configuration:config];
    self.webView.UIDelegate = self;
    self.webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 1280, 800)
                                              styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
                                                      | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    self.window.title = @"小黄鸭乐园";
    self.window.minSize = NSMakeSize(640, 480);
    self.window.backgroundColor = [NSColor colorWithSRGBRed:0.557 green:0.847 blue:0.973 alpha:1];
    self.window.contentView = self.webView;
    [self.window center];
    [self.window setFrameAutosaveName:@"BabyDuckMain"];

    NSURL *url = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
    if (url) {
        [self.webView loadFileURL:url allowingReadAccessToURL:url.URLByDeletingLastPathComponent];
    } else {
        [self.webView loadHTMLString:@"<h1 style='font-family:sans-serif'>缺少 index.html,请重新运行 build.sh</h1>" baseURL:nil];
    }

    NSMenu *menu = [[NSMenu alloc] init];
    NSMenuItem *item = [[NSMenuItem alloc] init];
    [menu addItem:item];
    NSMenu *submenu = [[NSMenu alloc] init];
    [submenu addItem:[[NSMenuItem alloc] initWithTitle:@"退出小黄鸭乐园"
                                                action:@selector(terminate:)
                                         keyEquivalent:@"q"]];
    item.submenu = submenu;
    NSApp.mainMenu = menu;

    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender { return YES; }

// 放行网页的麦克风请求,「听到宝宝发声就庆祝」才有机会工作;系统仍会弹出授权框。
- (void)webView:(WKWebView *)webView
    requestMediaCapturePermissionForOrigin:(WKSecurityOrigin *)origin
                          initiatedByFrame:(WKFrameInfo *)frame
                                      type:(WKMediaCaptureType)type
                            decisionHandler:(void (^)(WKPermissionDecision))decisionHandler {
    decisionHandler(WKPermissionDecisionGrant);
}

@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        app.delegate = delegate;
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];
        [app run];
    }
    return 0;
}
