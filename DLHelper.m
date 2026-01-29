#import "DLHelper.h"
#import "DLPrefs.h"
#import "FRPDeveloperCell.h"
#import "FRPSwitchCell.h"
#import "FRPSettings.h"
#import "MBProgressHUD.h"

static NSBundle *DLBundle(void) {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = @"/Library/Application Support/DLTwitter.bundle";
        bundle = [NSBundle bundleWithPath:path];
    });
    return bundle ?: [NSBundle mainBundle];
}

@implementation DLHelper

+ (BOOL)boolForKey:(id)key {
    if (!key) {
        return NO;
    }
    return [DLDefaults() boolForKey:key];
}

+ (void)setObject:(id)obj forKey:(id)key {
    if (!key) {
        return;
    }
    if (obj) {
        [DLDefaults() setObject:obj forKey:key];
    } else {
        [DLDefaults() removeObjectForKey:key];
    }
    [DLDefaults() synchronize];
}

+ (void)setBool:(BOOL)value forKey:(id)key {
    if (!key) {
        return;
    }
    [DLDefaults() setBool:value forKey:key];
    [DLDefaults() synchronize];
}

+ (id)cellWithTitle:(id)title detail:(id)detail image:(id)image url:(id)url {
    return [FRPDeveloperCell cellWithTitle:title detail:detail image:image url:url];
}

+ (id)cellWithTitle:(id)title key:(id)key defaultValue:(id)defaultValue {
    FRPSettings *settings = [FRPSettings settingsWithKey:key defaultValue:defaultValue];
    return [FRPSwitchCell cellWithTitle:title setting:settings postNotification:nil changeBlock:nil];
}

+ (void)vibration:(int)style {
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:(UIImpactFeedbackStyle)style];
    [generator impactOccurred];
}

+ (UIWindow *)keyWindow {
    UIWindow *key = [UIApplication sharedApplication].keyWindow;
    if (key) {
        return key;
    }
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (window.isKeyWindow) {
            return window;
        }
    }
    return [UIApplication sharedApplication].windows.firstObject;
}

+ (UIViewController *)topMostController {
    UIViewController *root = [self keyWindow].rootViewController;
    if (!root) {
        return nil;
    }
    UIViewController *current = root;
    while (current.presentedViewController) {
        current = current.presentedViewController;
    }
    if ([current isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)current topViewController];
    }
    if ([current isKindOfClass:[UITabBarController class]]) {
        return [(UITabBarController *)current selectedViewController];
    }
    return current;
}

+ (UIViewController *)getViewControllerFromView:(UIView *)view {
    UIResponder *responder = view;
    while (responder) {
        responder = [responder nextResponder];
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
}

+ (UIColor *)colorViewWithName:(id)name {
    if (![name isKindOfClass:[NSString class]]) {
        if (@available(iOS 13.0, *)) {
            return [UIColor systemBackgroundColor];
        }
        return [UIColor whiteColor];
    }
    NSString *key = (NSString *)name;
    if ([key.lowercaseString containsString:@"separator"]) {
        if (@available(iOS 13.0, *)) {
            return [UIColor separatorColor];
        }
        return [UIColor colorWithWhite:0.8 alpha:1.0];
    }
    if ([key.lowercaseString containsString:@"tint"]) {
        return [UIColor systemBlueColor];
    }
    if ([key.lowercaseString containsString:@"cell"]) {
        if (@available(iOS 13.0, *)) {
            return [UIColor secondarySystemBackgroundColor];
        }
        return [UIColor colorWithWhite:0.95 alpha:1.0];
    }
    if (@available(iOS 13.0, *)) {
        return [UIColor systemBackgroundColor];
    }
    return [UIColor whiteColor];
}

+ (unsigned long long)themeModeState {
    if (@available(iOS 13.0, *)) {
        UIUserInterfaceStyle style = [self keyWindow].traitCollection.userInterfaceStyle;
        return style == UIUserInterfaceStyleDark ? 1 : 0;
    }
    return 0;
}

+ (long long)getStatusCodeFromURL:(id)url {
    if (![url isKindOfClass:[NSURL class]]) {
        if ([url isKindOfClass:[NSString class]]) {
            url = [NSURL URLWithString:url];
        }
    }
    if (![url isKindOfClass:[NSURL class]]) {
        return -1;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"HEAD";
    NSURLResponse *response = nil;
    [self sendSynchronousRequest:request returningResponse:&response error:nil];
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        return ((NSHTTPURLResponse *)response).statusCode;
    }
    return -1;
}

+ (long long)DLMediaSize:(id)path {
    if (![path isKindOfClass:[NSString class]]) {
        return 0;
    }
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return (long long)[attrs fileSize];
}

+ (id)sendSynchronousRequest:(id)request returningResponse:(id *)response error:(id *)error {
    if (![request isKindOfClass:[NSURLRequest class]]) {
        return nil;
    }
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block NSData *data = nil;
    __block NSURLResponse *resp = nil;
    __block NSError *err = nil;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
        data = d;
        resp = r;
        err = e;
        dispatch_semaphore_signal(sema);
    }];
    [task resume];
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)));
    if (response) {
        *response = resp;
    }
    if (error) {
        *error = err;
    }
    return data;
}

+ (void)showAlertWithTitle:(id)title message:(id)message actions:(id)actions {
    UIViewController *vc = [self topMostController];
    if (!vc) {
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    if ([actions isKindOfClass:[NSArray class]]) {
        for (id action in (NSArray *)actions) {
            if ([action isKindOfClass:[UIAlertAction class]]) {
                [alert addAction:action];
            }
        }
    }
    if (alert.actions.count == 0) {
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"ACTION_DISMISS", nil, DLBundle(), @"") style:UIAlertActionStyleDefault handler:nil]];
    }
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)showConfirmMessageSave:(void (^)(void))save share:(void (^)(void))share {
    UIViewController *vc = [self topMostController];
    if (!vc) {
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromTableInBundle(@"ACTION_MESSAGE_SAVE_SHARE", nil, DLBundle(), @"") preferredStyle:UIAlertControllerStyleAlert];
    if (save) {
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"ACTION_SAVE", nil, DLBundle(), @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            save();
        }]];
    }
    if (share) {
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"ACTION_SHARE", nil, DLBundle(), @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            share();
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"ACTION_CANCEL", nil, DLBundle(), @"") style:UIAlertActionStyleCancel handler:nil]];
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)showAlertWithMessage:(id)message {
    [self showAlertWithTitle:nil message:message actions:nil];
}

+ (void)showMessageErrorInViewController:(UIViewController *)vc message:(id)message {
    if (!vc) {
        vc = [self topMostController];
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"ACTION_DISMISS", nil, DLBundle(), @"") style:UIAlertActionStyleDefault handler:nil]];
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (UIImage *)imageTintColor:(UIImage *)image withColor:(UIColor *)color {
    if (!image || !color) {
        return image;
    }
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect rect = (CGRect){.origin = CGPointZero, .size = image.size};
    CGContextTranslateCTM(ctx, 0, image.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    CGContextDrawImage(ctx, rect, image.CGImage);
    CGContextSetBlendMode(ctx, kCGBlendModeSourceIn);
    [color setFill];
    CGContextFillRect(ctx, rect);
    UIImage *tinted = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tinted;
}

+ (UIImage *)imageIcon:(id)name {
    if (![name isKindOfClass:[NSString class]]) {
        return nil;
    }
    UIImage *img = [UIImage imageNamed:name inBundle:DLBundle() compatibleWithTraitCollection:nil];
    if (img) {
        return img;
    }
    if (@available(iOS 13.0, *)) {
        return [UIImage systemImageNamed:name];
    }
    return nil;
}

+ (void)HUDWithState:(unsigned long long)state {
    UIWindow *window = [self keyWindow];
    if (!window) {
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD HUDForView:window];
    if (state == 0) {
        if (!hud) {
            hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
        }
        hud.label.text = @"Loading";
    } else if (state == 1) {
        if (!hud) {
            hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
        }
        hud.label.text = @"Done";
        [hud hideAnimated:YES afterDelay:1.0];
    } else if (state == 2) {
        if (!hud) {
            hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
        }
        hud.label.text = @"Error";
        [hud hideAnimated:YES afterDelay:1.2];
    } else {
        [hud hideAnimated:YES];
    }
}

@end
