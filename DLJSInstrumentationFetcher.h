#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface DLJSInstrumentationFetcher : NSObject <WKNavigationDelegate>

@property(retain) WKWebView *webView;
@property(copy) void (^completion)(id result);

+ (instancetype)sharedInstance;
- (void)fetchResultWithCompletion:(void (^)(id result))completion;

@end
