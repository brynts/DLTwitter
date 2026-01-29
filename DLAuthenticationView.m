#import "DLAuthenticationView.h"

@implementation DLAuthenticationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.authenticated = NO;
        [self setupBlurView];
    }
    return self;
}

- (void)setupBlurView {
    if (self.dlBlurView) {
        return;
    }
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.dlBlurView = [[UIVisualEffectView alloc] initWithEffect:effect];
    self.dlBlurView.frame = self.bounds;
    self.dlBlurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.dlBlurView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    id delegate = [UIApplication sharedApplication].delegate;
    if ([delegate respondsToSelector:@selector(window)]) {
        UIWindow *window = [delegate window];
        if (window && !CGRectEqualToRect(self.frame, window.bounds)) {
            self.frame = window.bounds;
        }
    }
    self.dlBlurView.frame = self.bounds;
}

- (void)contextAuthenticated:(void (^)(BOOL))completion {
    self.context = [[LAContext alloc] init];
    NSError *error = nil;
    LAPolicy policy = LAPolicyDeviceOwnerAuthentication;
    if ([self.context canEvaluatePolicy:policy error:&error]) {
        [self.context evaluatePolicy:policy localizedReason:@"Unlock" reply:^(BOOL success, NSError * _Nullable evalError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.authenticated = success;
                if (completion) {
                    completion(success);
                }
            });
        }];
    } else {
        self.authenticated = YES;
        if (completion) {
            completion(YES);
        }
    }
}

@end
