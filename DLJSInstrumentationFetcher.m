#import "DLJSInstrumentationFetcher.h"

@implementation DLJSInstrumentationFetcher

+ (instancetype)sharedInstance {
    static DLJSInstrumentationFetcher *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DLJSInstrumentationFetcher alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.webView = [[WKWebView alloc] initWithFrame:CGRectZero];
        self.webView.navigationDelegate = self;
    }
    return self;
}

- (void)fetchResultWithCompletion:(void (^)(id))completion {
    self.completion = completion;
    NSURL *url = [NSURL URLWithString:@"about:blank"]; 
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (decisionHandler) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    if (self.completion) {
        void (^block)(id) = self.completion;
        self.completion = nil;
        block(nil);
    }
}

@end
