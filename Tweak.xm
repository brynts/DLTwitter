#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <substrate.h>

#import "DLPrefs.h"
#import "DLHelper.h"
#import "DLAuthenticationView.h"
#import "DLPreferencesNavigationController.h"
#import "FRPreferences.h"
#import "FRPSection.h"
#import "FRPSwitchCell.h"
#import "FRPSliderCell.h"
#import "FRPSettings.h"
#import "FRPLinkCell.h"
#import "FRPDeveloperCell.h"
#import "FRPViewSection.h"
#import "FRPViewCell.h"
#import "DLBarButtonItem.h"
#import "DLSettingsButton.h"
#import "DLButton.h"
#import "DLTapGestureRecognizer.h"
#import "DLTwitterDownloader.h"
#import "DLDebuggingVC.h"

static NSBundle *DLBundle(void) {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<NSString *> *paths = @[
            @"/Library/Application Support/DLTwitter.bundle",
            @"/var/jb/Library/Application Support/DLTwitter.bundle",
            [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"DLTwitter.bundle"],
            [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"DLTwitter.bundle"]
        ];
        for (NSString *path in paths) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                bundle = [NSBundle bundleWithPath:path];
                break;
            }
        }
    });
    return bundle ?: [NSBundle mainBundle];
}

static NSString *DLLocalized(NSString *key) {
    NSString *value = NSLocalizedStringFromTableInBundle(key, nil, DLBundle(), @"");
    if (value && ![value isEqualToString:key]) {
        return value;
    }
    static NSDictionary<NSString *, NSString *> *fallback = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fallback = @{
            @"ACTION_CANCEL": @"Cancel",
            @"ACTION_CONFIRM": @"Confirm",
            @"ACTION_DISMISS": @"Dismiss",
            @"ACTION_DOWNLOAD": @"Download",
            @"ACTION_GIF": @"GIF",
            @"ACTION_MESSAGE_SAVE_SHARE": @"Saved. Share?",
            @"ACTION_MORE": @"More",
            @"ACTION_SAVE": @"Save",
            @"ACTION_SEND": @"Send",
            @"ACTION_SHARE": @"Share",
            @"ACTION_VIDEO": @"Video",
            @"ACTION_VIDEO_TITLE": @"Video",
            @"DOWNLOAD_SECTITLE": @"Download",
            @"DOWNLOAD_HIGHEST_QUALITY": @"Always download in highest quality",
            @"MEDIA_SECTITLE": @"Media",
            @"MEDIA_SHARE_MEDIA": @"Share media",
            @"MEDIA_NO_REPEAT_VIDEO": @"No repeat for videos",
            @"MEDIA_DISBALE_NEXT_VIDEO": @"Disable scrolling to next video",
            @"MEDIA_OLD_VIDEO_INTERFACE": @"Old video interface",
            @"MEDIA_TYPE_AUDIO": @"Audio",
            @"MEDIA_TYPE_VIDEO": @"Video",
            @"POPUP_SECTITLE": @"Popup Alert",
            @"POPUP_CONFIRM_FOLLOW": @"Confirm follow",
            @"POPUP_CONFIRM_FOLLOW_CELL": @"Ask before follow",
            @"POPUP_CONFIRM_LIKE_CELL": @"Ask before like",
            @"POPUP_CONFIRM_UNLIKE_CELL": @"Ask before unlike",
            @"POPUP_CONFIRM_LIKE_UNLIKE": @"Confirm Like/Unlike",
            @"DM_SECTITLE": @"Direct Messages",
            @"DM_DISABLE_TYPING_IND": @"Disable typing indicator",
            @"DM_ENABLE_VOICE": @"Enable voice message",
            @"BROWSER_SECTITLE": @"Browser",
            @"BROWSER_IN_SAFARI": @"Open links in safari",
            @"BROWSER_USER_THAT_BLOCKED_YOU": @"Browse the accounts that blocked you",
            @"BROWSER_OPEN_IN_BUTTON": @"Open in Browser",
            @"GENERIC": @"Generic",
            @"ENABLE_VOICE_TWEET": @"Enable voice tweet",
            @"ADS_REMOVE_PROMO_ADS": @"Remove promo Ads",
            @"ENABLE_TIP_JAR": @"Enable Tip Jar",
            @"COPY_PROFILE_INFO": @"Copy profile info",
            @"ALWAYS_SHOW_TRANSLATE_TWEET_BUTTON": @"Always show 'Translate Tweet' button",
            @"APP_LOCK_ENABLE": @"Enable",
            @"APP_LOCK_IMMEDIATELY": @"Immediately",
            @"DEVELOPER_SECTITLE": @"OpenSource",
            @"DEVELOPER_NAME": @"ZeroDeadBeef",
            @"DEVELOPER_SUPPORT_ACCOUNT": @"Support account",
            @"THANKS_SECTITLE": @"Simple POC OpenSource",
            @"THANKS_AGAIN": @"ZeroDeadBeef",
            @"HUD_DOWNLOADING": @"Downloading",
            @"HUD_CANCEL": @"Cancel"
        };
    });
    return fallback[key] ?: key;
}

static id DLSafeValueForKey(id obj, NSString *key) {
    if (!obj || !key) {
        return nil;
    }
    @try {
        return [obj valueForKey:key];
    } @catch (NSException *ex) {
        return nil;
    }
}

static void DLSafeSetValueForKey(id obj, NSString *key, id value) {
    if (!obj || !key) {
        return;
    }
    @try {
        [obj setValue:value forKey:key];
    } @catch (NSException *ex) {
    }
}

static NSURL *DLNormalizeURL(id value) {
    if (!value) {
        return nil;
    }
    if ([value isKindOfClass:[NSURL class]]) {
        return value;
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [NSURL URLWithString:value];
    }
    if ([value respondsToSelector:@selector(URL)]) {
        id nested = [value URL];
        if (nested != value) {
            NSURL *url = DLNormalizeURL(nested);
            if (url) return url;
        }
    }
    if ([value respondsToSelector:@selector(url)]) {
        id nested = [value url];
        if (nested != value) {
            NSURL *url = DLNormalizeURL(nested);
            if (url) return url;
        }
    }
    if ([value respondsToSelector:@selector(absoluteString)]) {
        id nested = [value absoluteString];
        if (nested != value) {
            NSURL *url = DLNormalizeURL(nested);
            if (url) return url;
        }
    }
    if ([value respondsToSelector:@selector(stringValue)]) {
        id nested = [value stringValue];
        if (nested != value) {
            NSURL *url = DLNormalizeURL(nested);
            if (url) return url;
        }
    }
    return nil;
}

static NSURL *DLFindVariantURL(NSArray *variants, BOOL highest) {
    NSURL *bestURL = nil;
    NSInteger bestBitrate = highest ? -1 : NSIntegerMax;
    for (id variant in variants) {
        id urlValue = DLSafeValueForKey(variant, @"url") ?: DLSafeValueForKey(variant, @"URL");
        NSURL *url = DLNormalizeURL(urlValue);
        if (!url) {
            continue;
        }
        NSNumber *bitrateNum = DLSafeValueForKey(variant, @"bitrate");
        NSInteger bitrate = bitrateNum ? [bitrateNum integerValue] : 0;
        if (highest) {
            if (bitrate >= bestBitrate) {
                bestBitrate = bitrate;
                bestURL = url;
            }
        } else {
            if (bitrate <= bestBitrate) {
                bestBitrate = bitrate;
                bestURL = url;
            }
        }
    }
    return bestURL;
}

static NSURL *DLURLFromAsset(id asset) {
    if (!asset) return nil;
    Class urlAssetClass = NSClassFromString(@"AVURLAsset");
    if (urlAssetClass && [asset isKindOfClass:urlAssetClass] && [asset respondsToSelector:@selector(URL)]) {
        return [asset URL];
    }
    if ([asset respondsToSelector:@selector(URL)]) {
        NSURL *url = [asset URL];
        if ([url isKindOfClass:[NSURL class]]) {
            return url;
        }
    }
    return nil;
}

static NSURL *DLFindVideoURLFromPlayerObject(id obj) {
    if (!obj) return nil;
    id player = DLSafeValueForKey(obj, @"player") ?: DLSafeValueForKey(obj, @"avPlayer") ?: DLSafeValueForKey(obj, @"videoPlayer");
    id playerItem = DLSafeValueForKey(player, @"currentItem") ?: DLSafeValueForKey(obj, @"currentItem") ?: DLSafeValueForKey(obj, @"playerItem");
    id asset = DLSafeValueForKey(playerItem, @"asset") ?: DLSafeValueForKey(obj, @"asset");
    NSURL *url = DLURLFromAsset(asset);
    if (url) return url;
    id urlValue = DLSafeValueForKey(playerItem, @"URL") ?: DLSafeValueForKey(obj, @"URL");
    return DLNormalizeURL(urlValue);
}

static NSURL *DLFindVideoURLFromObject(id obj) {
    if (!obj) return nil;
    NSURL *url = DLNormalizeURL(DLSafeValueForKey(obj, @"primaryMediaVideoURL"));
    if (url) return url;
    url = DLNormalizeURL(DLSafeValueForKey(obj, @"videoURL"));
    if (url) return url;
    url = DLNormalizeURL(DLSafeValueForKey(obj, @"videoURLString"));
    if (url) return url;
    url = DLNormalizeURL(DLSafeValueForKey(obj, @"primaryUrl"));
    if (url) return url;
    url = DLNormalizeURL(DLSafeValueForKey(obj, @"variantUri"));
    if (url) return url;

    id videoInfo = DLSafeValueForKey(obj, @"videoInfo");
    NSArray *variants = DLSafeValueForKey(videoInfo, @"variants");
    if ([variants isKindOfClass:[NSArray class]] && variants.count > 0) {
        BOOL highest = DLBool(kDL_EnableAlwaysDLHighQuality);
        return DLFindVariantURL(variants, highest);
    }
    id playbackState = DLSafeValueForKey(obj, @"lastPlaybackState");
    id performanceState = DLSafeValueForKey(playbackState, @"performanceState");
    url = DLNormalizeURL(DLSafeValueForKey(performanceState, @"variantUri"));
    if (url) return url;
    url = DLFindVideoURLFromPlayerObject(obj);
    if (url) return url;
    id playerLayer = DLSafeValueForKey(obj, @"playerLayer");
    if (playerLayer) {
        url = DLFindVideoURLFromPlayerObject(playerLayer);
        if (url) return url;
    }
    return nil;
}

static NSURL *DLFindImageURLFromObject(id obj) {
    if (!obj) return nil;
    NSURL *url = DLNormalizeURL(DLSafeValueForKey(obj, @"primaryMediaURL"));
    if (url) return url;
    url = DLNormalizeURL(DLSafeValueForKey(obj, @"mediaURL"));
    if (url) return url;
    url = DLNormalizeURL(DLSafeValueForKey(obj, @"mediaURLHttps"));
    if (url) return url;
    url = DLNormalizeURL(DLSafeValueForKey(obj, @"imageURL"));
    return url;
}

static NSURL *DLFindGIFURLFromObject(id obj) {
    if (!obj) return nil;
    NSURL *url = DLNormalizeURL(DLSafeValueForKey(obj, @"animatedImageURL"));
    if (url) return url;
    url = DLNormalizeURL(DLSafeValueForKey(obj, @"gifURL"));
    if (url) return url;
    return nil;
}

static id DLExtractMediaHost(id host) {
    if (!host) return nil;
    NSArray *keys = @[
        @"status",
        @"tweet",
        @"tweetModel",
        @"viewModel",
        @"statusViewModel",
        @"media",
        @"mediaEntity",
        @"primaryMedia",
        @"mediaItem",
        @"mediaModel",
        @"mediaViewModel",
        @"playerViewModel",
        @"playerItem",
        @"video",
        @"videoInfo",
        @"card",
        @"item"
    ];
    for (NSString *key in keys) {
        id candidate = DLSafeValueForKey(host, key);
        if (candidate) {
            return candidate;
        }
    }
    return host;
}

static BOOL DLIsTwitterHost(NSString *host) {
    if (!host) {
        return NO;
    }
    NSString *lower = host.lowercaseString;
    return [lower hasSuffix:@"twitter.com"] || [lower hasSuffix:@"x.com"] || [lower hasSuffix:@"t.co"] || [lower containsString:@"twitter"] || [lower containsString:@"x.com"];
}

static BOOL DLOpenURLIfExternal(NSURL *url) {
    if (!url) return NO;
    if (DLIsTwitterHost(url.host)) {
        return NO;
    }
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    return YES;
}

static NSMutableArray *gDLDownloaders;
static char kDLDownloaderKey;
static char kDLBlockedUsernameKey;
static char kDLAuthViewKey;
static char kDLAuthTapKey;
static char kDLCopyButtonKey;

static DLTwitterDownloader *DLCreateDownloaderForHost(id host) {
    if (!gDLDownloaders) {
        gDLDownloaders = [NSMutableArray array];
    }
    DLTwitterDownloader *downloader = [[DLTwitterDownloader alloc] init];
    [gDLDownloaders addObject:downloader];
    if (host) {
        objc_setAssociatedObject(host, &kDLDownloaderKey, downloader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return downloader;
}

static id DLDownloadHostForView(UIView *view) {
    if (!view) {
        return nil;
    }
    id host = DLExtractMediaHost(view);
    if (host && (DLFindVideoURLFromObject(host) || DLFindGIFURLFromObject(host) || DLSafeValueForKey(host, @"trailingEntityURL") || DLSafeValueForKey(host, @"_tfn_trailingEntityURL"))) {
        return host;
    }
    id viewModel = DLSafeValueForKey(view, @"viewModel") ?: DLSafeValueForKey(view, @"statusViewModel");
    if (viewModel && (DLFindVideoURLFromObject(viewModel) || DLFindGIFURLFromObject(viewModel) || DLSafeValueForKey(viewModel, @"trailingEntityURL") || DLSafeValueForKey(viewModel, @"_tfn_trailingEntityURL"))) {
        return viewModel;
    }
    UIResponder *responder = view;
    while (responder) {
        id candidate = DLExtractMediaHost(responder);
        if (candidate && (DLFindVideoURLFromObject(candidate) || DLFindGIFURLFromObject(candidate) || DLSafeValueForKey(candidate, @"trailingEntityURL") || DLSafeValueForKey(candidate, @"_tfn_trailingEntityURL"))) {
            return candidate;
        }
        id responderViewModel = DLSafeValueForKey(responder, @"viewModel") ?: DLSafeValueForKey(responder, @"statusViewModel");
        if (responderViewModel && (DLFindVideoURLFromObject(responderViewModel) || DLFindGIFURLFromObject(responderViewModel) || DLSafeValueForKey(responderViewModel, @"trailingEntityURL") || DLSafeValueForKey(responderViewModel, @"_tfn_trailingEntityURL"))) {
            return responderViewModel;
        }
        responder = [responder nextResponder];
    }
    return host ?: viewModel ?: view;
}

static id DLDownloadHostForObject(id obj) {
    if (!obj) {
        return nil;
    }
    if ([obj isKindOfClass:[UIView class]]) {
        return DLDownloadHostForView((UIView *)obj);
    }
    if ([obj respondsToSelector:@selector(view)]) {
        id view = [obj view];
        if ([view isKindOfClass:[UIView class]]) {
            id host = DLDownloadHostForView((UIView *)view);
            if (host) {
                return host;
            }
        }
    }
    id host = DLExtractMediaHost(obj);
    if (host && (DLFindVideoURLFromObject(host) || DLFindGIFURLFromObject(host) || DLSafeValueForKey(host, @"trailingEntityURL") || DLSafeValueForKey(host, @"_tfn_trailingEntityURL"))) {
        return host;
    }
    id viewModel = DLSafeValueForKey(obj, @"viewModel") ?: DLSafeValueForKey(obj, @"statusViewModel");
    if (viewModel && (DLFindVideoURLFromObject(viewModel) || DLFindGIFURLFromObject(viewModel) || DLSafeValueForKey(viewModel, @"trailingEntityURL") || DLSafeValueForKey(viewModel, @"_tfn_trailingEntityURL"))) {
        return viewModel;
    }
    return obj;
}

static NSInteger DLNormalizeMediaType(id value) {
    if ([value respondsToSelector:@selector(integerValue)]) {
        NSInteger mt = [value integerValue];
        if (mt == 1) return 1;
        if (mt == 3) return 3;
        return 2;
    }
    return 2;
}

static BOOL DLDownloadDirect(id host) {
    id mediaHost = DLExtractMediaHost(host);
    id entity = DLSafeValueForKey(mediaHost, @"trailingEntityURL") ?: DLSafeValueForKey(mediaHost, @"_tfn_trailingEntityURL");
    if (entity) {
        id urlValue = DLSafeValueForKey(entity, @"url") ?: DLSafeValueForKey(entity, @"URL");
        if (!urlValue) {
            urlValue = DLSafeValueForKey(entity, @"primaryUrl") ?: DLSafeValueForKey(entity, @"variantUri");
        }
        if (!urlValue) {
            urlValue = DLSafeValueForKey(entity, @"expandedURL") ?: DLSafeValueForKey(entity, @"expandedURLString");
        }
        NSURL *url = DLNormalizeURL(urlValue);
        if (url) {
            NSInteger mediaType = DLNormalizeMediaType(DLSafeValueForKey(entity, @"mediaType"));
            DLTwitterDownloader *downloader = DLCreateDownloaderForHost(host);
            [downloader downloadMediaURLString:url mediaType:mediaType];
            return YES;
        }
    }

    NSURL *videoURL = DLFindVideoURLFromObject(mediaHost);
    NSURL *imageURL = DLFindImageURLFromObject(mediaHost);
    NSURL *gifURL = DLFindGIFURLFromObject(mediaHost);
    if (!videoURL && !gifURL && !imageURL) {
        return NO;
    }
    DLTwitterDownloader *downloader = DLCreateDownloaderForHost(host);
    if (gifURL) {
        [downloader downloadMediaURLString:gifURL mediaType:3];
    } else if (videoURL) {
        [downloader downloadMediaURLString:videoURL mediaType:2];
    } else if (imageURL) {
        [downloader downloadMediaURLString:imageURL mediaType:1];
    }
    return YES;
}

static void DLShowDownloadMenu(id host, UIView *sourceView) {
    id mediaHost = DLExtractMediaHost(host);
    NSURL *videoURL = DLFindVideoURLFromObject(mediaHost);
    NSURL *imageURL = DLFindImageURLFromObject(mediaHost);
    NSURL *gifURL = DLFindGIFURLFromObject(mediaHost);
    if (!videoURL && !gifURL && !imageURL) {
        return;
    }

    UIViewController *vc = [DLHelper topMostController];
    if (!vc) {
        return;
    }

    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:DLLocalized(@"ACTION_DOWNLOAD") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [sheet addAction:[UIAlertAction actionWithTitle:DLLocalized(@"ACTION_DOWNLOAD") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (!DLDownloadDirect(host)) {
            DLTwitterDownloader *downloader = DLCreateDownloaderForHost(host);
            if (gifURL) {
                [downloader downloadMediaURLString:gifURL mediaType:3];
            } else if (videoURL) {
                [downloader downloadMediaURLString:videoURL mediaType:2];
            } else if (imageURL) {
                [downloader downloadMediaURLString:imageURL mediaType:1];
            }
        }
    }]];

    if (DLBool(kDL_EnableShareMedia)) {
        [sheet addAction:[UIAlertAction actionWithTitle:DLLocalized(@"ACTION_SHARE") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            id shareItem = videoURL ?: gifURL ?: imageURL;
            if (!shareItem && [host isKindOfClass:[UIView class]]) {
                UIGraphicsBeginImageContextWithOptions(((UIView *)host).bounds.size, NO, [UIScreen mainScreen].scale);
                [host drawViewHierarchyInRect:((UIView *)host).bounds afterScreenUpdates:YES];
                shareItem = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            if (shareItem) {
                UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[shareItem] applicationActivities:nil];
                [vc presentViewController:activity animated:YES completion:nil];
            }
        }]];
    }

    [sheet addAction:[UIAlertAction actionWithTitle:DLLocalized(@"ACTION_CANCEL") style:UIAlertActionStyleCancel handler:nil]];
    if (sourceView) {
        sheet.popoverPresentationController.sourceView = sourceView;
        sheet.popoverPresentationController.sourceRect = sourceView.bounds;
    }
    [vc presentViewController:sheet animated:YES completion:nil];
}

static char kDLDownloadButtonKey;
static const CGFloat kDLDownloadButtonSize = 24.0;
static const CGFloat kDLDownloadButtonPadding = 10.0;

static UIImage *DLDownloadIconImage(void) {
    UIImage *icon = [DLHelper imageIcon:@"download_40pt"];
    if (!icon) {
        icon = [DLHelper imageIcon:@"arrow.down"];
    }
    if (icon) {
        icon = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return icon;
}

static UIButton *DLCreateOverlayDownloadButton(UIView *target) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *icon = DLDownloadIconImage();
    if (icon) {
        [button setImage:icon forState:UIControlStateNormal];
    }
    button.tintColor = [UIColor whiteColor];
    button.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    button.contentEdgeInsets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    button.adjustsImageWhenHighlighted = NO;
    button.clipsToBounds = YES;
    [button addTarget:target action:@selector(dl_didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

static UIButton *DLCreateStackDownloadButton(UIView *target, UIView *referenceView) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *icon = DLDownloadIconImage();
    if (icon) {
        [button setImage:icon forState:UIControlStateNormal];
    }
    UIColor *tint = referenceView.tintColor ?: [UIColor whiteColor];
    button.tintColor = tint;
    button.backgroundColor = [UIColor clearColor];
    if ([referenceView isKindOfClass:[UIButton class]]) {
        UIButton *refButton = (UIButton *)referenceView;
        button.contentEdgeInsets = refButton.contentEdgeInsets;
        button.imageEdgeInsets = refButton.imageEdgeInsets;
        button.contentHorizontalAlignment = refButton.contentHorizontalAlignment;
        button.contentVerticalAlignment = refButton.contentVerticalAlignment;
    } else {
        button.contentEdgeInsets = UIEdgeInsetsZero;
    }
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [button addTarget:target action:@selector(dl_didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

static void DLEnsureDownloadButtonOnStatusView(UIView *view) {
    if (!view) return;
    NSNumber *attachmentType = DLSafeValueForKey(view, @"attachmentType");
    if ([attachmentType respondsToSelector:@selector(integerValue)]) {
        if ([attachmentType integerValue] != 3) {
            return;
        }
    } else {
        id host = DLDownloadHostForView(view);
        NSNumber *mediaTypeNum = DLSafeValueForKey(host, @"mediaType");
        if ([mediaTypeNum respondsToSelector:@selector(integerValue)] && [mediaTypeNum integerValue] == 1) {
            return;
        }
        if (!DLFindVideoURLFromObject(host) && !DLFindGIFURLFromObject(host)) {
            return;
        }
    }
    UIButton *button = objc_getAssociatedObject(view, &kDLDownloadButtonKey);
    if (!button) {
        button = DLCreateOverlayDownloadButton(view);
        objc_setAssociatedObject(view, &kDLDownloadButtonKey, button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    if (button.superview != view) {
        [button removeFromSuperview];
        [view addSubview:button];
    }
    UIView *container = DLSafeValueForKey(view, @"inlineVideoView");
    if (!container) {
        container = DLSafeValueForKey(view, @"mediaContainerView");
    }
    CGRect refFrame = container ? [view convertRect:container.bounds fromView:container] : view.bounds;
    CGFloat size = kDLDownloadButtonSize;
    CGFloat padding = kDLDownloadButtonPadding;
    button.frame = CGRectMake(CGRectGetMaxX(refFrame) - size - padding, CGRectGetMinY(refFrame) + padding, size, size);
    button.layer.cornerRadius = size * 0.5;
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
}

static void DLEnsureDownloadButtonOnExploreCard(UIView *view) {
    static char kDLExploreLongPressKey;
    if (view && !objc_getAssociatedObject(view, &kDLExploreLongPressKey)) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:view action:@selector(dl_exploreLongPress:)];
        [view addGestureRecognizer:longPress];
        objc_setAssociatedObject(view, &kDLExploreLongPressKey, longPress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    DLEnsureDownloadButtonOnStatusView(view);
}

static void DLEnsureDownloadButtonOnPlaybackStackView(UIView *view) {
    if (!view) return;
    Class stackClass = NSClassFromString(@"UIStackView");
    if (!stackClass || ![view isKindOfClass:stackClass]) {
        return;
    }
    UIStackView *stack = (UIStackView *)view;
    UIButton *button = objc_getAssociatedObject(stack, &kDLDownloadButtonKey);
    if (!button) {
        UIView *reference = nil;
        for (UIView *subview in stack.arrangedSubviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                reference = subview;
                break;
            }
        }
        reference = reference ?: stack;
        button = DLCreateStackDownloadButton(stack, reference);
        objc_setAssociatedObject(stack, &kDLDownloadButtonKey, button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    if (button.superview != stack) {
        [button removeFromSuperview];
        [stack addArrangedSubview:button];
    }
    UIColor *tint = nil;
    for (UIView *subview in stack.arrangedSubviews) {
        if ([subview isKindOfClass:[UIButton class]] && subview != button) {
            tint = subview.tintColor;
            break;
        }
    }
    if (!tint) {
        tint = stack.tintColor;
    }
    if (tint) {
        button.tintColor = tint;
    }
    button.translatesAutoresizingMaskIntoConstraints = NO;
    if (!objc_getAssociatedObject(button, @selector(dlButton))) {
        [NSLayoutConstraint activateConstraints:@[
            [button.widthAnchor constraintEqualToConstant:kDLDownloadButtonSize],
            [button.heightAnchor constraintEqualToConstant:kDLDownloadButtonSize]
        ]];
        objc_setAssociatedObject(button, @selector(dlButton), @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@interface NSObject (DLDownloadButton)
- (UIButton *)dlButton;
- (void)setDlButton:(UIButton *)button;
- (void)dl_didPressButton:(UIButton *)sender;
- (void)dl_exploreLongPress:(UILongPressGestureRecognizer *)recognizer;
@end

@implementation NSObject (DLDownloadButton)
- (UIButton *)dlButton {
    return objc_getAssociatedObject(self, &kDLDownloadButtonKey);
}

- (void)setDlButton:(UIButton *)button {
    objc_setAssociatedObject(self, &kDLDownloadButtonKey, button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dl_didPressButton:(UIButton *)sender {
    id host = self;
    if ([self isKindOfClass:[UIView class]]) {
        host = DLDownloadHostForView((UIView *)self);
    }
    if ((!host || host == self) && [sender isKindOfClass:[UIView class]]) {
        host = DLDownloadHostForView(sender);
    }
    if (!DLDownloadDirect(host)) {
        DLShowDownloadMenu(host, sender);
    }
}

- (void)dl_exploreLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    id host = self;
    if ([self isKindOfClass:[UIView class]]) {
        host = DLDownloadHostForView((UIView *)self);
    }
    DLShowDownloadMenu(host, (UIView *)recognizer.view);
}
@end

static const NSInteger kDLHeaderTitleTag = 0x6f;
static const NSInteger kDLHeaderVersionTag = 0xde;

static NSString *DLDebuggingPasscode(void) {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:[NSDate date]];
    NSString *dayString = [NSString stringWithFormat:@"%ld", (long)components.day];
    return [@"-" stringByAppendingString:dayString];
}

static void DLShowDebuggingAlert(void) {
    UIViewController *top = [DLHelper topMostController];
    if (!top) return;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DLDebugging"
                                                                   message:@"This is only for purpose of showing debugging"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:nil];
    __weak UIAlertController *weakAlert = alert;
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = weakAlert.textFields.firstObject.text ?: @"";
        if ([input isEqualToString:DLDebuggingPasscode()]) {
            DLDebuggingVC *vc = [[DLDebuggingVC alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [top presentViewController:nav animated:YES completion:nil];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:ok];
    [alert addAction:cancel];
    [top presentViewController:alert animated:YES completion:nil];
}

static FRPSection *DLBuildHeaderSection(void) {
    return [FRPViewSection sectionWithHeight:80 initBlock:^(FRPViewCell *cell) {
        cell.backgroundColor = [UIColor clearColor];

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
        UIFont *titleFont = [UIFont fontWithName:@"ArialRoundedMTBold" size:40.0];
        if (!titleFont) {
            titleFont = [UIFont boldSystemFontOfSize:40.0];
        }
        title.font = titleFont;
        title.text = @"DLTwitter";
        title.textAlignment = NSTextAlignmentCenter;
        title.alpha = 0.0;
        title.tag = kDLHeaderTitleTag;
        title.userInteractionEnabled = YES;
        [cell addSubview:title];

        DLTapGestureRecognizer *tap = [[DLTapGestureRecognizer alloc] initWithAction:^{
            DLShowDebuggingAlert();
        }];
        tap.numberOfTapsRequired = 10;
        [title addGestureRecognizer:tap];

        UILabel *version = [[UILabel alloc] initWithFrame:CGRectZero];
        UIFont *versionFont = [UIFont fontWithName:@"ArialRoundedMTBold" size:13.0];
        if (!versionFont) {
            versionFont = [UIFont systemFontOfSize:13.0];
        }
        version.font = versionFont;
        version.text = @"v2.1.6";
        version.textAlignment = NSTextAlignmentCenter;
        version.numberOfLines = 0;
        version.alpha = 0.0;
        version.tag = kDLHeaderVersionTag;
        [cell addSubview:version];

        [UIView animateWithDuration:1.0 animations:^{
            title.alpha = 1.0;
        }];
        [UIView animateWithDuration:2.0 animations:^{
            version.alpha = 1.0;
        }];
    } layoutBlock:^(UIView *contentView) {
        UILabel *title = (UILabel *)[contentView viewWithTag:kDLHeaderTitleTag];
        UILabel *version = (UILabel *)[contentView viewWithTag:kDLHeaderVersionTag];
        CGFloat width = contentView.bounds.size.width;
        if (title) {
            title.frame = CGRectMake(0.0, -5.0, width, 60.0);
        }
        if (version) {
            version.frame = CGRectMake(0.0, 30.0, width, 60.0);
        }
    }];
}

static void DLConfigureNavItems(FRPreferences *prefs) {
    __weak FRPreferences *weakPrefs = prefs;
    DLBarButtonItem *cancel = [[DLBarButtonItem alloc] initWithTitle:DLLocalized(@"ACTION_CANCEL") style:UIBarButtonItemStylePlain action:^{
        [weakPrefs dismissViewControllerAnimated:YES completion:nil];
    }];
    prefs.navigationItem.leftBarButtonItem = cancel;

    UIImage *heart = [DLHelper imageIcon:@"Heart.png"];
    if (!heart) {
        heart = [DLHelper imageIcon:@"heart"];
    }
    DLBarButtonItem *support = [[DLBarButtonItem alloc] initWithImage:heart style:UIBarButtonItemStylePlain action:^{
        NSURL *url = [NSURL URLWithString:@"https://t.me/ZeroxDeadBeef"];
        if (url) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }];
    prefs.navigationItem.rightBarButtonItem = support;

    UIImage *downloadIcon = [DLHelper imageIcon:@"download_40pt"];
    if (!downloadIcon) {
        downloadIcon = [DLHelper imageIcon:@"arrow.down"];
    }
    if (downloadIcon) {
        UIImageView *titleView = [[UIImageView alloc] initWithImage:downloadIcon];
        titleView.contentMode = UIViewContentModeScaleAspectFit;
        titleView.frame = CGRectMake(0, 0, 24, 24);
        prefs.navigationItem.titleView = titleView;
    }
}

static FRPreferences *DLBuildPreferencesController(void) {
    FRPSection *header = DLBuildHeaderSection();
    FRPSection *download = [FRPSection sectionWithTitle:DLLocalized(@"DOWNLOAD_SECTITLE") footer:nil];
    [download addCell:[FRPSwitchCell cellWithTitle:DLLocalized(@"DOWNLOAD_HIGHEST_QUALITY") setting:[FRPSettings settingsWithKey:kDL_EnableAlwaysDLHighQuality defaultValue:@(NO)] postNotification:nil changeBlock:nil]];

    FRPSection *media = [FRPSection sectionWithTitle:DLLocalized(@"MEDIA_SECTITLE") footer:nil];
    [media addCell:[FRPSwitchCell cellWithTitle:DLLocalized(@"MEDIA_SHARE_MEDIA") setting:[FRPSettings settingsWithKey:kDL_EnableShareMedia defaultValue:@(NO)] postNotification:nil changeBlock:nil]];
    [media addCell:[FRPSwitchCell cellWithTitle:DLLocalized(@"MEDIA_NO_REPEAT_VIDEO") setting:[FRPSettings settingsWithKey:kDL_EnableDisableLoopVideo defaultValue:@(NO)] postNotification:nil changeBlock:nil]];
    [media addCell:[FRPSwitchCell cellWithTitle:DLLocalized(@"MEDIA_DISBALE_NEXT_VIDEO") setting:[FRPSettings settingsWithKey:kDL_DisableNextVideo defaultValue:@(NO)] postNotification:nil changeBlock:nil]];

    FRPSection *popup = [FRPSection sectionWithTitle:DLLocalized(@"POPUP_SECTITLE") footer:nil];
    [popup addCell:[FRPSwitchCell cellWithTitle:DLLocalized(@"POPUP_CONFIRM_FOLLOW") setting:[FRPSettings settingsWithKey:kDL_EnableConfirmFollow defaultValue:@(NO)] postNotification:nil changeBlock:nil]];
    [popup addCell:[FRPSwitchCell cellWithTitle:DLLocalized(@"POPUP_CONFIRM_LIKE_UNLIKE") setting:[FRPSettings settingsWithKey:kDL_EnableConfirmLike_UnLike defaultValue:@(NO)] postNotification:nil changeBlock:nil]];

    FRPSection *directMessages = [FRPSection sectionWithTitle:DLLocalized(@"DM_SECTITLE") footer:nil];
    [directMessages addCell:[FRPSwitchCell cellWithTitle:DLLocalized(@"DM_DISABLE_TYPING_IND") setting:[FRPSettings settingsWithKey:kDL_DisableTypingIndicatorInDM defaultValue:@(NO)] postNotification:nil changeBlock:nil]];
    [directMessages addCell:[FRPSwitchCell cellWithTitle:DLLocalized(@"DM_ENABLE_VOICE") setting:[FRPSettings settingsWithKey:kDL_EnableVoiceInDM defaultValue:@(NO)] postNotification:nil changeBlock:nil]];

    FRPSection *browser = [FRPSection sectionWithTitle:DLLocalized(@"BROWSER_SECTITLE") footer:nil];
    [browser addCell:[FRPSwitchCell cellWithTitle:DLLocalized(@"BROWSER_IN_SAFARI") setting:[FRPSettings settingsWithKey:kDL_EnableOpenLinksInSafari defaultValue:@(NO)] postNotification:nil changeBlock:nil]];
    [browser addCell:[FRPSwitchCell cellWithTitle:DLLocalized(@"BROWSER_USER_THAT_BLOCKED_YOU") setting:[FRPSettings settingsWithKey:kDL_EnableBrowseAccountsBlockedYou defaultValue:@(NO)] postNotification:nil changeBlock:nil]];

    FRPSection *generic = [FRPSection sectionWithTitle:DLLocalized(@"GENERIC") footer:nil];
    [generic addCell:[FRPSwitchCell cellWithTitle:DLLocalized(@"ENABLE_VOICE_TWEET") setting:[FRPSettings settingsWithKey:kDL_EnableVoiceTweet defaultValue:@(NO)] postNotification:nil changeBlock:nil]];
    [generic addCell:[FRPSwitchCell cellWithTitle:DLLocalized(@"ADS_REMOVE_PROMO_ADS") setting:[FRPSettings settingsWithKey:kDL_EnableRemoveAd defaultValue:@(NO)] postNotification:nil changeBlock:nil]];
    [generic addCell:[FRPSwitchCell cellWithTitle:DLLocalized(@"ENABLE_TIP_JAR") setting:[FRPSettings settingsWithKey:kDL_EnableTipJar defaultValue:@(NO)] postNotification:nil changeBlock:nil]];
    [generic addCell:[FRPSwitchCell cellWithTitle:DLLocalized(@"COPY_PROFILE_INFO") setting:[FRPSettings settingsWithKey:kDL_EnableCopyProfileInfo defaultValue:@(NO)] postNotification:nil changeBlock:nil]];
    [generic addCell:[FRPSwitchCell cellWithTitle:DLLocalized(@"ALWAYS_SHOW_TRANSLATE_TWEET_BUTTON") setting:[FRPSettings settingsWithKey:kDL_AlwyasShowTranslateTweet defaultValue:@(NO)] postNotification:nil changeBlock:nil]];

    FRPSection *appLock = [FRPSection sectionWithTitle:@"App Lock" footer:nil];
    [appLock addCell:[FRPSwitchCell cellWithTitle:DLLocalized(@"APP_LOCK_ENABLE") setting:[FRPSettings settingsWithKey:kDL_EnableAppLock defaultValue:@(NO)] postNotification:nil changeBlock:nil]];

    FRPSection *developer = [FRPSection sectionWithTitle:DLLocalized(@"DEVELOPER_SECTITLE") footer:nil];
    UIImage *twitterIcon = [DLHelper imageIcon:@"twitter.png"];
    [developer addCell:[FRPDeveloperCell cellWithTitle:DLLocalized(@"DEVELOPER_NAME") detail:@"@ZeroDeadBeef" image:twitterIcon url:@"https://twitter.com/ZeroDeadBeef"]];
    [developer addCell:[FRPDeveloperCell cellWithTitle:DLLocalized(@"DEVELOPER_SUPPORT_ACCOUNT") detail:@"@ZeroDeadBeef" image:twitterIcon url:@"https://twitter.com/ZeroDeadBeef"]];
    UIImage *heartIcon = [DLHelper imageIcon:@"Heart.png"];
    [developer addCell:[FRPDeveloperCell cellWithTitle:@"Join Channel" detail:@"ZeroxDeadBeef" image:heartIcon url:@"https://t.me/ZeroxDeadBeef"]];

    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"11.48";
    NSString *footerVersion = [NSString stringWithFormat:@"v%@ - v2.1.6", appVersion];
    FRPSection *thanks = [FRPSection sectionWithTitle:DLLocalized(@"THANKS_SECTITLE") footer:footerVersion];
    [thanks addCell:[FRPDeveloperCell cellWithTitle:DLLocalized(@"THANKS_AGAIN") detail:@"@ZeroDeadBeef" image:twitterIcon url:@"https://twitter.com/ZeroDeadBeef"]];

    NSArray *sections = @[header, download, media, popup, directMessages, browser, generic, appLock, developer, thanks];
    FRPreferences *prefs = [FRPreferences tableWithSections:sections title:@"DLTwitter" tintColor:[UIColor whiteColor]];
    prefs.view.backgroundColor = [UIColor blackColor];
    if ([prefs respondsToSelector:@selector(tableView)]) {
        prefs.tableView.backgroundColor = [UIColor blackColor];
        prefs.tableView.separatorColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    }
    DLConfigureNavItems(prefs);
    return prefs;
}

static void DLPresentPreferences(UIViewController *vc) {
    FRPreferences *prefs = DLBuildPreferencesController();
    DLPreferencesNavigationController *nav = [[DLPreferencesNavigationController alloc] initWithRootViewController:prefs];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [vc presentViewController:nav animated:YES completion:nil];
}

static char kDLSettingsButtonKey;

static id (*orig_T1AppSplitHostView_initWithFrame_hostedView_hasDivider)(id, SEL, CGRect, id, BOOL);
static id hook_T1AppSplitHostView_initWithFrame_hostedView_hasDivider(id self, SEL _cmd, CGRect frame, id hostedView, BOOL hasDivider) {
    id obj = orig_T1AppSplitHostView_initWithFrame_hostedView_hasDivider
        ? orig_T1AppSplitHostView_initWithFrame_hostedView_hasDivider(self, _cmd, frame, hostedView, hasDivider)
        : self;
    if (!hasDivider || !hostedView || ![hostedView isKindOfClass:[UIView class]]) {
        return obj;
    }
    UIView *container = (UIView *)hostedView;
    if (objc_getAssociatedObject(container, &kDLSettingsButtonKey)) {
        return obj;
    }

    DLSettingsButton *button = [DLSettingsButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:@"DLTwitter" forState:UIControlStateNormal];
    if (@available(iOS 8.2, *)) {
        button.titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightBold];
    } else {
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    }
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 16.0;
    __weak UIViewController *weakVC = [DLHelper topMostController];
    [button actionHandler:^{
        if (weakVC) {
            DLPresentPreferences(weakVC);
        }
    }];

    [container addSubview:button];
    CGFloat width = button.intrinsicContentSize.width + 30.0;
    [NSLayoutConstraint activateConstraints:@[
        [button.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [button.bottomAnchor constraintEqualToAnchor:container.safeAreaLayoutGuide.bottomAnchor constant:-12.0],
        [button.heightAnchor constraintEqualToConstant:32.0],
        [button.widthAnchor constraintEqualToConstant:width]
    ]];
    objc_setAssociatedObject(container, &kDLSettingsButtonKey, button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return obj;
}

// Global state for blocked profile button
static NSInteger gDLBlockedState = 0;
static NSString *gDLBlockedUsername = nil;

// Hook helpers
static void DLHookInstanceMethod(Class cls, SEL sel, IMP imp, IMP *orig) {
    if (!cls || !sel) return;
    Method m = class_getInstanceMethod(cls, sel);
    if (!m) return;
    MSHookMessageEx(cls, sel, imp, orig);
}

static void DLHookClassMethod(Class cls, SEL sel, IMP imp, IMP *orig) {
    if (!cls || !sel) return;
    Class meta = object_getClass(cls);
    if (!meta) return;
    Method m = class_getInstanceMethod(meta, sel);
    if (!m) return;
    MSHookMessageEx(meta, sel, imp, orig);
}

// TAVPlaylistItem prefersLooping
static BOOL (*orig_TAVPlaylistItem_prefersLooping)(id, SEL);
static BOOL hook_TAVPlaylistItem_prefersLooping(id self, SEL _cmd) {
    if (DLBool(kDL_EnableDisableLoopVideo)) {
        return NO;
    }
    return orig_TAVPlaylistItem_prefersLooping ? orig_TAVPlaylistItem_prefersLooping(self, _cmd) : NO;
}

// TPSTwitterFeatureSwitches boolForKey:
static BOOL (*orig_TPSTwitterFeatureSwitches_boolForKey)(id, SEL, id);
static BOOL (*orig_TPSTwitterFeatureSwitches_class_boolForKey)(id, SEL, id);

static BOOL DLHandleFeatureSwitch(id self, SEL _cmd, id key, BOOL (*orig)(id, SEL, id)) {
    NSString *k = [key isKindOfClass:[NSString class]] ? (NSString *)key : [key description];
    if (DLBool(kDL_EnableOldVideoInterface)) {
        if ([k.lowercaseString containsString:@"immersive"] || [k.lowercaseString containsString:@"explore"] || [k.lowercaseString containsString:@"full_screen_video"]) {
            return NO;
        }
    }
    if (DLBool(kDL_EnableRemoveAd)) {
        NSString *lower = k.lowercaseString;
        if ([lower containsString:@"ad_"] || [lower containsString:@"ads_"] || [lower containsString:@"adformats"] || [lower containsString:@"promoted"] || [lower containsString:@"ads_enabled"]) {
            return NO;
        }
    }
    if (DLBool(kDL_EnableVoiceInDM)) {
        if ([k isEqualToString:@"dm_voice_creation_enabled"] || [k isEqualToString:@"dm_replay_later_enabled"]) {
            return YES;
        }
    }
    if (DLBool(kDL_EnableVoiceTweet)) {
        if ([k isEqualToString:@"voice_creation_enabled"] || [k isEqualToString:@"voice_replies_enabled"]) {
            return YES;
        }
    }
    return orig ? orig(self, _cmd, key) : NO;
}

static BOOL hook_TPSTwitterFeatureSwitches_boolForKey(id self, SEL _cmd, id key) {
    return DLHandleFeatureSwitch(self, _cmd, key, orig_TPSTwitterFeatureSwitches_boolForKey);
}

static BOOL hook_TPSTwitterFeatureSwitches_class_boolForKey(id self, SEL _cmd, id key) {
    return DLHandleFeatureSwitch(self, _cmd, key, orig_TPSTwitterFeatureSwitches_class_boolForKey);
}

// Immersive explore disable next video
static void (*orig_T1ImmersiveExploreViewController_viewDidLoad)(id, SEL);
static void hook_T1ImmersiveExploreViewController_viewDidLoad(id self, SEL _cmd) {
    if (orig_T1ImmersiveExploreViewController_viewDidLoad) {
        orig_T1ImmersiveExploreViewController_viewDidLoad(self, _cmd);
    }
    if (DLBool(kDL_DisableNextVideo)) {
        id viewModel = DLSafeValueForKey(self, @"viewModel");
        if (viewModel) {
            DLSafeSetValueForKey(viewModel, @"isAutoPlayNextEnabled", @(NO));
            DLSafeSetValueForKey(viewModel, @"autoPlayNextEnabled", @(NO));
        }
    }
}

static void (*orig_T1ImmersiveExploreViewController_handleVerticalPan)(id, SEL, id);
static void hook_T1ImmersiveExploreViewController_handleVerticalPan(id self, SEL _cmd, id gesture) {
    if (DLBool(kDL_DisableNextVideo)) {
        return;
    }
    if (orig_T1ImmersiveExploreViewController_handleVerticalPan) {
        orig_T1ImmersiveExploreViewController_handleVerticalPan(self, _cmd, gesture);
    }
}

// Follow confirm
static void (*orig_T1FollowControl_followUser)(id, SEL, id, id);
static void hook_T1FollowControl_followUser(id self, SEL _cmd, id user, id event) {
    if (!DLBool(kDL_EnableConfirmFollow)) {
        if (orig_T1FollowControl_followUser) {
            orig_T1FollowControl_followUser(self, _cmd, user, event);
        }
        return;
    }
    [DLHelper showAlertWithTitle:nil message:DLLocalized(@"POPUP_CONFIRM_FOLLOW") actions:@[
        [UIAlertAction actionWithTitle:DLLocalized(@"ACTION_CANCEL") style:UIAlertActionStyleCancel handler:nil],
        [UIAlertAction actionWithTitle:DLLocalized(@"ACTION_CONFIRM") style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
            if (orig_T1FollowControl_followUser) {
                orig_T1FollowControl_followUser(self, _cmd, user, event);
            }
        }]
    ]];
}

static void (*orig_TUIFollowControl_followUser)(id, SEL, id, id);
static void hook_TUIFollowControl_followUser(id self, SEL _cmd, id user, id event) {
    if (!DLBool(kDL_EnableConfirmFollow)) {
        if (orig_TUIFollowControl_followUser) {
            orig_TUIFollowControl_followUser(self, _cmd, user, event);
        }
        return;
    }
    [DLHelper showAlertWithTitle:nil message:DLLocalized(@"POPUP_CONFIRM_FOLLOW") actions:@[
        [UIAlertAction actionWithTitle:DLLocalized(@"ACTION_CANCEL") style:UIAlertActionStyleCancel handler:nil],
        [UIAlertAction actionWithTitle:DLLocalized(@"ACTION_CONFIRM") style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
            if (orig_TUIFollowControl_followUser) {
                orig_TUIFollowControl_followUser(self, _cmd, user, event);
            }
        }]
    ]];
}

// Like/unlike confirm
static void (*orig_TFNTwitterAccount_favoriteStatus)(id, SEL, id, id);
static void hook_TFNTwitterAccount_favoriteStatus(id self, SEL _cmd, id status, id block) {
    if (!DLBool(kDL_EnableConfirmLike_UnLike)) {
        if (orig_TFNTwitterAccount_favoriteStatus) {
            orig_TFNTwitterAccount_favoriteStatus(self, _cmd, status, block);
        }
        return;
    }
    [DLHelper showAlertWithTitle:nil message:@"Like this tweet?" actions:@[
        [UIAlertAction actionWithTitle:DLLocalized(@"ACTION_CANCEL") style:UIAlertActionStyleCancel handler:nil],
        [UIAlertAction actionWithTitle:DLLocalized(@"ACTION_CONFIRM") style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
            if (orig_TFNTwitterAccount_favoriteStatus) {
                orig_TFNTwitterAccount_favoriteStatus(self, _cmd, status, block);
            }
        }]
    ]];
}

static void (*orig_TFNTwitterAccount_unfavoriteStatus)(id, SEL, id, id);
static void hook_TFNTwitterAccount_unfavoriteStatus(id self, SEL _cmd, id status, id block) {
    if (!DLBool(kDL_EnableConfirmLike_UnLike)) {
        if (orig_TFNTwitterAccount_unfavoriteStatus) {
            orig_TFNTwitterAccount_unfavoriteStatus(self, _cmd, status, block);
        }
        return;
    }
    [DLHelper showAlertWithTitle:nil message:@"Unlike this tweet?" actions:@[
        [UIAlertAction actionWithTitle:DLLocalized(@"ACTION_CANCEL") style:UIAlertActionStyleCancel handler:nil],
        [UIAlertAction actionWithTitle:DLLocalized(@"ACTION_CONFIRM") style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
            if (orig_TFNTwitterAccount_unfavoriteStatus) {
                orig_TFNTwitterAccount_unfavoriteStatus(self, _cmd, status, block);
            }
        }]
    ]];
}

// Tip jar
static BOOL (*orig_TFNTwitterAccount_isProfileTipJarSettingsEnabled)(id, SEL);
static BOOL hook_TFNTwitterAccount_isProfileTipJarSettingsEnabled(id self, SEL _cmd) {
    if (DLBool(kDL_EnableTipJar)) {
        return YES;
    }
    return orig_TFNTwitterAccount_isProfileTipJarSettingsEnabled ? orig_TFNTwitterAccount_isProfileTipJarSettingsEnabled(self, _cmd) : NO;
}

// Disable typing indicator
static id (*orig_TFSTwitterAPIDirectMessageConversationTypingCommand_init)(id, SEL, id, id, id, id);
static id hook_TFSTwitterAPIDirectMessageConversationTypingCommand_init(id self, SEL _cmd, id accountID, id conversationID, id context, id completion) {
    if (DLBool(kDL_DisableTypingIndicatorInDM)) {
        context = nil;
    }
    return orig_TFSTwitterAPIDirectMessageConversationTypingCommand_init ? orig_TFSTwitterAPIDirectMessageConversationTypingCommand_init(self, _cmd, accountID, conversationID, context, completion) : self;
}

// Blocked accounts
static long long (*orig_T1ProfileUserViewModel_blockingViewerRelationshipState)(id, SEL);
static long long hook_T1ProfileUserViewModel_blockingViewerRelationshipState(id self, SEL _cmd) {
    long long state = orig_T1ProfileUserViewModel_blockingViewerRelationshipState ? orig_T1ProfileUserViewModel_blockingViewerRelationshipState(self, _cmd) : 0;
    gDLBlockedState = state;
    return state;
}

static id (*orig_T1ProfileUserViewModel_username)(id, SEL);
static id hook_T1ProfileUserViewModel_username(id self, SEL _cmd) {
    id username = orig_T1ProfileUserViewModel_username ? orig_T1ProfileUserViewModel_username(self, _cmd) : nil;
    if (gDLBlockedState != 0 && [username isKindOfClass:[NSString class]]) {
        gDLBlockedUsername = username;
    }
    return username;
}

static void DLAddBlockedProfileButton(UIViewController *vc) {
    if (!DLBool(kDL_EnableBrowseAccountsBlockedYou)) {
        return;
    }
    if (gDLBlockedState == 0 || gDLBlockedUsername.length == 0) {
        return;
    }
    if (objc_getAssociatedObject(vc, @selector(DLAddBlockedProfileButton))) {
        return;
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:DLLocalized(@"BROWSER_OPEN_IN_BUTTON") forState:UIControlStateNormal];
    button.frame = CGRectMake(20, 20, 200, 44);
    [button addTarget:nil action:@selector(dlOpenBlockedProfile:) forControlEvents:UIControlEventTouchUpInside];
    objc_setAssociatedObject(button, &kDLBlockedUsernameKey, gDLBlockedUsername, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [vc.view addSubview:button];
    objc_setAssociatedObject(vc, @selector(DLAddBlockedProfileButton), button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@interface NSObject (DLBlocked)
- (void)dlOpenBlockedProfile:(UIButton *)sender;
@end

@implementation NSObject (DLBlocked)
- (void)dlOpenBlockedProfile:(UIButton *)sender {
    NSString *username = objc_getAssociatedObject(sender, &kDLBlockedUsernameKey);
    if (username.length == 0) return;
    NSString *urlString = [NSString stringWithFormat:@"https://x.com/%@", username];
    NSURL *url = [NSURL URLWithString:urlString];
    if (url) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}
@end

static id (*orig_T1LegacyEmptyProfileInterstitialViewController_init)(id, SEL, id, long long);
static id hook_T1LegacyEmptyProfileInterstitialViewController_init(id self, SEL _cmd, id message, long long style) {
    id obj = orig_T1LegacyEmptyProfileInterstitialViewController_init ? orig_T1LegacyEmptyProfileInterstitialViewController_init(self, _cmd, message, style) : self;
    DLAddBlockedProfileButton(obj);
    return obj;
}

static id (*orig_TFNEmptyStateViewController_init)(id, SEL, id);
static id hook_TFNEmptyStateViewController_init(id self, SEL _cmd, id config) {
    id obj = orig_TFNEmptyStateViewController_init ? orig_TFNEmptyStateViewController_init(self, _cmd, config) : self;
    DLAddBlockedProfileButton(obj);
    return obj;
}

// Open links in Safari
static id (*orig_T1SafariViewController_init)(id, SEL, id, id, id, BOOL, id, id);
static id hook_T1SafariViewController_init(id self, SEL _cmd, id url, id account, id status, BOOL reader, id scribeComponent, id scribeParams) {
    NSURL *theURL = DLNormalizeURL(url);
    if (DLBool(kDL_EnableOpenLinksInSafari) && DLOpenURLIfExternal(theURL)) {
        id obj = orig_T1SafariViewController_init ? orig_T1SafariViewController_init(self, _cmd, url, account, status, reader, scribeComponent, scribeParams) : self;
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *vc = (UIViewController *)obj;
            if ([vc respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
                [vc dismissViewControllerAnimated:YES completion:nil];
            }
        });
        return obj;
    }
    return orig_T1SafariViewController_init ? orig_T1SafariViewController_init(self, _cmd, url, account, status, reader, scribeComponent, scribeParams) : self;
}

static void (*orig_T1StandardStatusBodyViewAdapter_tap)(id, SEL, id, id);
static void hook_T1StandardStatusBodyViewAdapter_tap(id self, SEL _cmd, id textView, id activeRange) {
    if (DLBool(kDL_EnableOpenLinksInSafari)) {
        id urlValue = DLSafeValueForKey(activeRange, @"URL") ?: DLSafeValueForKey(activeRange, @"url");
        NSURL *url = DLNormalizeURL(urlValue);
        if (url && DLOpenURLIfExternal(url)) {
            return;
        }
    }
    if (orig_T1StandardStatusBodyViewAdapter_tap) {
        orig_T1StandardStatusBodyViewAdapter_tap(self, _cmd, textView, activeRange);
    }
}

// App lock
@interface NSObject (DLAppLockView)
- (DLAuthenticationView *)authenticationView;
- (void)setAuthenticationView:(DLAuthenticationView *)view;
@end

@implementation NSObject (DLAppLockView)
- (DLAuthenticationView *)authenticationView {
    return objc_getAssociatedObject(self, &kDLAuthViewKey);
}

- (void)setAuthenticationView:(DLAuthenticationView *)view {
    objc_setAssociatedObject(self, &kDLAuthViewKey, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

static UIWindow *DLAppLockWindow(id self) {
    if ([self respondsToSelector:@selector(window)]) {
        UIWindow *window = [self window];
        if (window) {
            return window;
        }
    }
    return [DLHelper keyWindow];
}

static void (*orig_T1AppDelegate_applicationDidBecomeActive)(id, SEL, id);
static void hook_T1AppDelegate_applicationDidBecomeActive(id self, SEL _cmd, id app) {
    if (orig_T1AppDelegate_applicationDidBecomeActive) {
        orig_T1AppDelegate_applicationDidBecomeActive(self, _cmd, app);
    }
    if (!DLBool(kDL_EnableAppLock)) {
        DLAuthenticationView *authView = [self authenticationView];
        if (authView.superview) {
            [authView removeFromSuperview];
        }
        return;
    }

    NSTimeInterval delay = [[DLDefaults() objectForKey:kDL_DelayAppLock] doubleValue];
    NSDate *last = [DLDefaults() objectForKey:kDL_faceIdSaveDate];
    if (last && delay > 0) {
        if ([[NSDate date] timeIntervalSinceDate:last] < delay) {
            DLAuthenticationView *authView = [self authenticationView];
            if (authView.superview) {
                [authView removeFromSuperview];
            }
            return;
        }
    }

    UIWindow *window = DLAppLockWindow(self);
    if (!window) {
        return;
    }
    DLAuthenticationView *authView = [self authenticationView];
    if (!authView) {
        authView = [[DLAuthenticationView alloc] initWithFrame:window.bounds];
        authView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self setAuthenticationView:authView];
    }
    authView.frame = window.bounds;
    authView.authenticated = NO;
    if (!authView.superview) {
        [window addSubview:authView];
    }

    if (DLBool(kDL_ProtectWithFaceId)) {
        [authView contextAuthenticated:^(BOOL success) {
            if (success) {
                [authView removeFromSuperview];
                [DLDefaults() setObject:[NSDate date] forKey:kDL_faceIdSaveDate];
                [DLDefaults() synchronize];
            }
        }];
    }
    if (!objc_getAssociatedObject(authView, &kDLAuthTapKey)) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:authView action:@selector(dlUnlockTap:)];
        [authView addGestureRecognizer:tap];
        objc_setAssociatedObject(authView, &kDLAuthTapKey, tap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

static void (*orig_T1AppDelegate_applicationWillResignActive)(id, SEL, id);
static void hook_T1AppDelegate_applicationWillResignActive(id self, SEL _cmd, id app) {
    if (orig_T1AppDelegate_applicationWillResignActive) {
        orig_T1AppDelegate_applicationWillResignActive(self, _cmd, app);
    }
    if (!DLBool(kDL_EnableAppLock)) {
        return;
    }
    UIWindow *window = DLAppLockWindow(self);
    if (!window) {
        return;
    }
    DLAuthenticationView *authView = [self authenticationView];
    if (!authView) {
        authView = [[DLAuthenticationView alloc] initWithFrame:window.bounds];
        authView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self setAuthenticationView:authView];
    }
    authView.frame = window.bounds;
    authView.authenticated = NO;
    if (!authView.superview) {
        [window addSubview:authView];
    }
    [DLDefaults() setObject:[NSDate date] forKey:kDL_faceIdSaveDate];
    [DLDefaults() synchronize];
}

static void (*orig_T1AppDelegate_applicationWillTerminate)(id, SEL, id);
static void hook_T1AppDelegate_applicationWillTerminate(id self, SEL _cmd, id app) {
    if (orig_T1AppDelegate_applicationWillTerminate) {
        orig_T1AppDelegate_applicationWillTerminate(self, _cmd, app);
    }
    DLAuthenticationView *authView = [self authenticationView];
    if (authView.superview) {
        [authView removeFromSuperview];
    }
}

@interface DLAuthenticationView (DLUnlock)
- (void)dlUnlockTap:(UITapGestureRecognizer *)tap;
@end

@implementation DLAuthenticationView (DLUnlock)
- (void)dlUnlockTap:(UITapGestureRecognizer *)tap {
    if (DLBool(kDL_ProtectWithFaceId)) {
        [self contextAuthenticated:^(BOOL success) {
            if (success) {
                [self removeFromSuperview];
                [DLDefaults() setObject:[NSDate date] forKey:kDL_faceIdSaveDate];
                [DLDefaults() synchronize];
            }
        }];
        return;
    }
    [self removeFromSuperview];
    [DLDefaults() setObject:[NSDate date] forKey:kDL_faceIdSaveDate];
    [DLDefaults() synchronize];
}
@end

// Copy profile info
static void DLAddCopyButtonToProfileView(id view) {
    if (!DLBool(kDL_EnableCopyProfileInfo)) {
        return;
    }
    if (![view isKindOfClass:[UIView class]]) {
        return;
    }
    UIView *container = (UIView *)view;
    UIButton *button = objc_getAssociatedObject(container, &kDLCopyButtonKey);
    if (!button) {
        button = [UIButton buttonWithType:UIButtonTypeSystem];
        UIImage *icon = [DLHelper imageIcon:@"doc.on.doc"]; 
        if (icon) {
            [button setImage:icon forState:UIControlStateNormal];
        } else {
            [button setTitle:@"Copy" forState:UIControlStateNormal];
        }
        [button addTarget:nil action:@selector(dl_didPressCopyButton:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(container, &kDLCopyButtonKey, button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [container addSubview:button];
    }
    CGFloat size = 28.0;
    button.frame = CGRectMake(container.bounds.size.width - size - 8.0, container.bounds.size.height - size - 8.0, size, size);
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
}

@interface NSObject (DLProfileCopy)
- (void)dl_didPressCopyButton:(UIButton *)sender;
@end

@implementation NSObject (DLProfileCopy)
- (void)dl_didPressCopyButton:(UIButton *)sender {
    id view = sender.superview;
    id viewModel = DLSafeValueForKey(view, @"viewModel") ?: DLSafeValueForKey(view, @"userViewModel");
    NSString *username = DLSafeValueForKey(viewModel, @"username") ?: DLSafeValueForKey(viewModel, @"screenName");
    NSString *name = DLSafeValueForKey(viewModel, @"name") ?: DLSafeValueForKey(viewModel, @"displayName");
    NSString *text = nil;
    if (username && name) {
        text = [NSString stringWithFormat:@"%@ (@%@)", name, username];
    } else if (username) {
        text = [NSString stringWithFormat:@"@%@", username];
    } else if (name) {
        text = name;
    }
    if (text.length > 0) {
        [UIPasteboard generalPasteboard].string = text;
        [DLHelper HUDWithState:1];
    }
}
@end

static void (*orig_T1ProfileActionButtonsView_layoutSubviews)(id, SEL);
static void hook_T1ProfileActionButtonsView_layoutSubviews(id self, SEL _cmd) {
    if (orig_T1ProfileActionButtonsView_layoutSubviews) {
        orig_T1ProfileActionButtonsView_layoutSubviews(self, _cmd);
    }
    DLAddCopyButtonToProfileView(self);
}

static id (*orig_T1ProfileActionButtonsView_initWithFrame)(id, SEL, CGRect);
static id hook_T1ProfileActionButtonsView_initWithFrame(id self, SEL _cmd, CGRect frame) {
    id obj = orig_T1ProfileActionButtonsView_initWithFrame ? orig_T1ProfileActionButtonsView_initWithFrame(self, _cmd, frame) : self;
    DLAddCopyButtonToProfileView(obj);
    return obj;
}

// Always show translate
static BOOL (*orig_TFNTwitterStatus_isTranslatable)(id, SEL);
static BOOL hook_TFNTwitterStatus_isTranslatable(id self, SEL _cmd) {
    if (DLBool(kDL_AlwyasShowTranslateTweet)) {
        return YES;
    }
    return orig_TFNTwitterStatus_isTranslatable ? orig_TFNTwitterStatus_isTranslatable(self, _cmd) : NO;
}

// Ads removal helpers
static BOOL DLIsPromotedItem(id item) {
    if (!item) return NO;
    if ([item respondsToSelector:@selector(isPromoted)]) {
        BOOL promoted = ((BOOL (*)(id, SEL))objc_msgSend)(item, @selector(isPromoted));
        if (promoted) return YES;
    }
    NSString *cls = NSStringFromClass([item class]);
    if ([cls containsString:@"Ad"] || [cls containsString:@"Promoted"] || [cls containsString:@"GoogleNativeAd"]) {
        return YES;
    }
    return NO;
}

static id (*orig_TFNItemsDataViewAdapterRegistry_dataViewAdapterForItem)(id, SEL, id);
static id hook_TFNItemsDataViewAdapterRegistry_dataViewAdapterForItem(id self, SEL _cmd, id item) {
    if (DLBool(kDL_EnableRemoveAd) && DLIsPromotedItem(item)) {
        return nil;
    }
    return orig_TFNItemsDataViewAdapterRegistry_dataViewAdapterForItem ? orig_TFNItemsDataViewAdapterRegistry_dataViewAdapterForItem(self, _cmd, item) : nil;
}

static id (*orig_TFNItemsDataViewController_tableViewCellForItem)(id, SEL, id, id);
static id hook_TFNItemsDataViewController_tableViewCellForItem(id self, SEL _cmd, id item, id indexPath) {
    id cell = orig_TFNItemsDataViewController_tableViewCellForItem ? orig_TFNItemsDataViewController_tableViewCellForItem(self, _cmd, item, indexPath) : nil;
    if (DLBool(kDL_EnableRemoveAd) && DLIsPromotedItem(item)) {
        if ([cell isKindOfClass:[UIView class]]) {
            ((UIView *)cell).hidden = YES;
        }
    }
    return cell;
}

static id DLItemForIndexPath(id self, id indexPath) {
    SEL selectors[] = {@selector(itemAtIndexPath:), @selector(itemForIndexPath:), @selector(dataViewItemAtIndexPath:)};
    for (int i = 0; i < 3; i++) {
        SEL sel = selectors[i];
        if ([self respondsToSelector:sel]) {
            id (*msg)(id, SEL, id) = (id (*)(id, SEL, id))objc_msgSend;
            id item = msg(self, sel, indexPath);
            if (item) return item;
        }
    }
    return nil;
}

static double (*orig_TFNItemsDataViewController_heightForRow)(id, SEL, id, id);
static double hook_TFNItemsDataViewController_heightForRow(id self, SEL _cmd, id table, id indexPath) {
    if (DLBool(kDL_EnableRemoveAd)) {
        id item = DLItemForIndexPath(self, indexPath);
        if (DLIsPromotedItem(item)) {
            return 0.0;
        }
    }
    return orig_TFNItemsDataViewController_heightForRow ? orig_TFNItemsDataViewController_heightForRow(self, _cmd, table, indexPath) : 0.0;
}

static double (*orig_TFNItemsDataViewController_heightForHeader)(id, SEL, id, long long);
static double hook_TFNItemsDataViewController_heightForHeader(id self, SEL _cmd, id table, long long section) {
    return orig_TFNItemsDataViewController_heightForHeader ? orig_TFNItemsDataViewController_heightForHeader(self, _cmd, table, section) : 0.0;
}

static BOOL (*orig_TFNTwitterStatus_isCardHidden)(id, SEL);
static BOOL hook_TFNTwitterStatus_isCardHidden(id self, SEL _cmd) {
    if (DLBool(kDL_EnableRemoveAd) && DLIsPromotedItem(self)) {
        return YES;
    }
    return orig_TFNTwitterStatus_isCardHidden ? orig_TFNTwitterStatus_isCardHidden(self, _cmd) : NO;
}

// Media buttons
static void (*orig_T1StatusPhotoVideoForwardView_layoutSubviews)(id, SEL);
static void hook_T1StatusPhotoVideoForwardView_layoutSubviews(id self, SEL _cmd) {
    if (orig_T1StatusPhotoVideoForwardView_layoutSubviews) {
        orig_T1StatusPhotoVideoForwardView_layoutSubviews(self, _cmd);
    }
    DLEnsureDownloadButtonOnStatusView((UIView *)self);
}

static void (*orig_T1ImmersiveExploreCardView_layoutSubviews)(id, SEL);
static void hook_T1ImmersiveExploreCardView_layoutSubviews(id self, SEL _cmd) {
    if (orig_T1ImmersiveExploreCardView_layoutSubviews) {
        orig_T1ImmersiveExploreCardView_layoutSubviews(self, _cmd);
    }
    DLEnsureDownloadButtonOnExploreCard((UIView *)self);
}

static void (*orig_T1TwitterSwift_ImmersiveInlinePlaybackButtonsStackView_didMoveToSuperview)(id, SEL);
static void hook_T1TwitterSwift_ImmersiveInlinePlaybackButtonsStackView_didMoveToSuperview(id self, SEL _cmd) {
    if (orig_T1TwitterSwift_ImmersiveInlinePlaybackButtonsStackView_didMoveToSuperview) {
        orig_T1TwitterSwift_ImmersiveInlinePlaybackButtonsStackView_didMoveToSuperview(self, _cmd);
    }
    DLEnsureDownloadButtonOnPlaybackStackView((UIView *)self);
}

static void (*orig_T1TwitterSwift_ImmersiveExploreCardView_presentShareSheet)(id, SEL, id);
static void hook_T1TwitterSwift_ImmersiveExploreCardView_presentShareSheet(id self, SEL _cmd, id arg) {
    DLShowDownloadMenu(DLDownloadHostForObject(self ?: arg), nil);
    if (orig_T1TwitterSwift_ImmersiveExploreCardView_presentShareSheet) {
        orig_T1TwitterSwift_ImmersiveExploreCardView_presentShareSheet(self, _cmd, arg);
    }
}

static void (*orig_T1SlideshowViewController_longPress)(id, SEL, id, id);
static void hook_T1SlideshowViewController_longPress(id self, SEL _cmd, id controller, id recognizer) {
    if ([recognizer respondsToSelector:@selector(state)] && ((UIGestureRecognizer *)recognizer).state == UIGestureRecognizerStateBegan) {
        DLShowDownloadMenu(DLDownloadHostForObject(controller ?: self), nil);
    }
    if (orig_T1SlideshowViewController_longPress) {
        orig_T1SlideshowViewController_longPress(self, _cmd, controller, recognizer);
    }
}

// Settings button in controllers
__attribute__((constructor)) static void DLTwitterInit(void) {
    @autoreleasepool {
        Class splitHost = objc_getClass("T1AppSplitHostView");
        if (splitHost) {
            DLHookInstanceMethod(splitHost, @selector(initWithFrame:hostedView:hasDivider:), (IMP)hook_T1AppSplitHostView_initWithFrame_hostedView_hasDivider, (IMP *)&orig_T1AppSplitHostView_initWithFrame_hostedView_hasDivider);
        }

        DLHookInstanceMethod(objc_getClass("TAVPlaylistItem"), @selector(prefersLooping), (IMP)hook_TAVPlaylistItem_prefersLooping, (IMP *)&orig_TAVPlaylistItem_prefersLooping);

        Class feature = objc_getClass("TPSTwitterFeatureSwitches");
        DLHookInstanceMethod(feature, @selector(boolForKey:), (IMP)hook_TPSTwitterFeatureSwitches_boolForKey, (IMP *)&orig_TPSTwitterFeatureSwitches_boolForKey);
        DLHookClassMethod(feature, @selector(boolForKey:), (IMP)hook_TPSTwitterFeatureSwitches_class_boolForKey, (IMP *)&orig_TPSTwitterFeatureSwitches_class_boolForKey);

        DLHookInstanceMethod(objc_getClass("T1ImmersiveExploreViewController"), @selector(viewDidLoad), (IMP)hook_T1ImmersiveExploreViewController_viewDidLoad, (IMP *)&orig_T1ImmersiveExploreViewController_viewDidLoad);
        DLHookInstanceMethod(objc_getClass("T1ImmersiveExploreViewController"), @selector(handleVerticalPan:), (IMP)hook_T1ImmersiveExploreViewController_handleVerticalPan, (IMP *)&orig_T1ImmersiveExploreViewController_handleVerticalPan);

        DLHookInstanceMethod(objc_getClass("T1FollowControl"), @selector(_followUser:event:), (IMP)hook_T1FollowControl_followUser, (IMP *)&orig_T1FollowControl_followUser);
        DLHookInstanceMethod(objc_getClass("TUIFollowControl"), @selector(_followUser:event:), (IMP)hook_TUIFollowControl_followUser, (IMP *)&orig_TUIFollowControl_followUser);

        DLHookInstanceMethod(objc_getClass("TFNTwitterAccount"), @selector(favoriteStatus:responseBlock:), (IMP)hook_TFNTwitterAccount_favoriteStatus, (IMP *)&orig_TFNTwitterAccount_favoriteStatus);
        DLHookInstanceMethod(objc_getClass("TFNTwitterAccount"), @selector(unfavoriteStatus:responseBlock:), (IMP)hook_TFNTwitterAccount_unfavoriteStatus, (IMP *)&orig_TFNTwitterAccount_unfavoriteStatus);
        DLHookInstanceMethod(objc_getClass("TFNTwitterAccount"), @selector(isProfileTipJarSettingsEnabled), (IMP)hook_TFNTwitterAccount_isProfileTipJarSettingsEnabled, (IMP *)&orig_TFNTwitterAccount_isProfileTipJarSettingsEnabled);

        DLHookInstanceMethod(objc_getClass("TFSTwitterAPIDirectMessageConversationTypingCommand"), @selector(initWithAccountID:conversationID:context:completionBlock:), (IMP)hook_TFSTwitterAPIDirectMessageConversationTypingCommand_init, (IMP *)&orig_TFSTwitterAPIDirectMessageConversationTypingCommand_init);

        DLHookInstanceMethod(objc_getClass("T1ProfileUserViewModel"), @selector(blockingViewerRelationshipState), (IMP)hook_T1ProfileUserViewModel_blockingViewerRelationshipState, (IMP *)&orig_T1ProfileUserViewModel_blockingViewerRelationshipState);
        DLHookInstanceMethod(objc_getClass("T1ProfileUserViewModel"), @selector(username), (IMP)hook_T1ProfileUserViewModel_username, (IMP *)&orig_T1ProfileUserViewModel_username);

        DLHookInstanceMethod(objc_getClass("T1LegacyEmptyProfileInterstitialViewController"), @selector(initWithEmptyContentMessage:style:), (IMP)hook_T1LegacyEmptyProfileInterstitialViewController_init, (IMP *)&orig_T1LegacyEmptyProfileInterstitialViewController_init);
        DLHookInstanceMethod(objc_getClass("TFNEmptyStateViewController"), @selector(initWithConfiguration:), (IMP)hook_TFNEmptyStateViewController_init, (IMP *)&orig_TFNEmptyStateViewController_init);

        DLHookInstanceMethod(objc_getClass("T1SafariViewController"), @selector(initWithRootURL:account:sourceStatus:entersReaderIfAvailable:scribeComponent:scribeParameters:), (IMP)hook_T1SafariViewController_init, (IMP *)&orig_T1SafariViewController_init);
        DLHookInstanceMethod(objc_getClass("T1StandardStatusBodyViewAdapter"), @selector(bodyTextView:didTapActiveTextRange:), (IMP)hook_T1StandardStatusBodyViewAdapter_tap, (IMP *)&orig_T1StandardStatusBodyViewAdapter_tap);

        DLHookInstanceMethod(objc_getClass("T1AppDelegate"), @selector(applicationDidBecomeActive:), (IMP)hook_T1AppDelegate_applicationDidBecomeActive, (IMP *)&orig_T1AppDelegate_applicationDidBecomeActive);
        DLHookInstanceMethod(objc_getClass("T1AppDelegate"), @selector(applicationWillResignActive:), (IMP)hook_T1AppDelegate_applicationWillResignActive, (IMP *)&orig_T1AppDelegate_applicationWillResignActive);
        DLHookInstanceMethod(objc_getClass("T1AppDelegate"), @selector(applicationWillTerminate:), (IMP)hook_T1AppDelegate_applicationWillTerminate, (IMP *)&orig_T1AppDelegate_applicationWillTerminate);

        DLHookInstanceMethod(objc_getClass("T1ProfileActionButtonsView"), @selector(layoutSubviews), (IMP)hook_T1ProfileActionButtonsView_layoutSubviews, (IMP *)&orig_T1ProfileActionButtonsView_layoutSubviews);
        DLHookInstanceMethod(objc_getClass("T1ProfileActionButtonsView"), @selector(initWithFrame:), (IMP)hook_T1ProfileActionButtonsView_initWithFrame, (IMP *)&orig_T1ProfileActionButtonsView_initWithFrame);

        DLHookInstanceMethod(objc_getClass("TFNTwitterStatus"), @selector(isTranslatable), (IMP)hook_TFNTwitterStatus_isTranslatable, (IMP *)&orig_TFNTwitterStatus_isTranslatable);

        DLHookInstanceMethod(objc_getClass("TFNItemsDataViewAdapterRegistry"), @selector(dataViewAdapterForItem:), (IMP)hook_TFNItemsDataViewAdapterRegistry_dataViewAdapterForItem, (IMP *)&orig_TFNItemsDataViewAdapterRegistry_dataViewAdapterForItem);
        DLHookInstanceMethod(objc_getClass("TFNItemsDataViewController"), @selector(tableViewCellForItem:atIndexPath:), (IMP)hook_TFNItemsDataViewController_tableViewCellForItem, (IMP *)&orig_TFNItemsDataViewController_tableViewCellForItem);
        DLHookInstanceMethod(objc_getClass("TFNItemsDataViewController"), @selector(tableView:heightForRowAtIndexPath:), (IMP)hook_TFNItemsDataViewController_heightForRow, (IMP *)&orig_TFNItemsDataViewController_heightForRow);
        DLHookInstanceMethod(objc_getClass("TFNItemsDataViewController"), @selector(tableView:heightForHeaderInSection:), (IMP)hook_TFNItemsDataViewController_heightForHeader, (IMP *)&orig_TFNItemsDataViewController_heightForHeader);
        DLHookInstanceMethod(objc_getClass("TFNTwitterStatus"), @selector(isCardHidden), (IMP)hook_TFNTwitterStatus_isCardHidden, (IMP *)&orig_TFNTwitterStatus_isCardHidden);

        DLHookInstanceMethod(objc_getClass("T1StatusPhotoVideoForwardView"), @selector(layoutSubviews), (IMP)hook_T1StatusPhotoVideoForwardView_layoutSubviews, (IMP *)&orig_T1StatusPhotoVideoForwardView_layoutSubviews);
        DLHookInstanceMethod(objc_getClass("T1ImmersiveExploreCardView"), @selector(layoutSubviews), (IMP)hook_T1ImmersiveExploreCardView_layoutSubviews, (IMP *)&orig_T1ImmersiveExploreCardView_layoutSubviews);
        DLHookInstanceMethod(objc_getClass("T1TwitterSwift.ImmersiveInlinePlaybackButtonsStackView"), @selector(didMoveToSuperview), (IMP)hook_T1TwitterSwift_ImmersiveInlinePlaybackButtonsStackView_didMoveToSuperview, (IMP *)&orig_T1TwitterSwift_ImmersiveInlinePlaybackButtonsStackView_didMoveToSuperview);
        DLHookInstanceMethod(objc_getClass("T1TwitterSwift.ImmersiveExploreCardView"), @selector(presentShareSheet:), (IMP)hook_T1TwitterSwift_ImmersiveExploreCardView_presentShareSheet, (IMP *)&orig_T1TwitterSwift_ImmersiveExploreCardView_presentShareSheet);
        DLHookInstanceMethod(objc_getClass("T1SlideshowViewController"), @selector(slideshowSeekController:didLongPressWithRecognizer:), (IMP)hook_T1SlideshowViewController_longPress, (IMP *)&orig_T1SlideshowViewController_longPress);
    }
}
