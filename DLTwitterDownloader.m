#import "DLTwitterDownloader.h"
#import "DLDownloaderMinimizeView.h"
#import "MBProgressHUD.h"
#import "DLHelper.h"
#import "DLSaveMedia.h"
#import "DLPrefs.h"

@implementation DLTwitterDownloader

+ (NSString *)documentsDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.firstObject ?: NSTemporaryDirectory();
}

- (void)downloadMediaURLString:(id)urlString mediaType:(unsigned long long)type {
    NSURL *url = nil;
    if ([urlString isKindOfClass:[NSURL class]]) {
        url = (NSURL *)urlString;
    } else if ([urlString isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:(NSString *)urlString];
    }
    if (!url) {
        [DLHelper showAlertWithMessage:@"Invalid URL."];
        return;
    }

    self.mediaType = type;

    UIWindow *window = [DLHelper keyWindow];
    if (window) {
        self.hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
        self.hud.label.text = @"Downloading";
    }

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.task = [session downloadTaskWithURL:url];
    [self.task resume];

    [self setupMinimizeView];
}

- (void)setupMinimizeView {
    UIWindow *window = [DLHelper keyWindow];
    if (!window || self.minimizeView) {
        return;
    }
    CGFloat size = 60.0;
    self.minimizeView = [[DLDownloaderMinimizeView alloc] initWithFrame:CGRectMake(window.bounds.size.width - size - 16.0, window.bounds.size.height - size - 100.0, size, size)];
    self.minimizeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [window addSubview:self.minimizeView];
}

- (void)cancel {
    [self.task cancel];
    [self removeViewAndHideHUD];
}

- (void)DLHUDHide {
    [self.hud hideAnimated:YES];
}

- (void)whenHideHUD {
    [self removeViewAndHideHUD];
}

- (void)showHUDAgain {
    UIWindow *window = [DLHelper keyWindow];
    if (window && !self.hud) {
        self.hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    }
}

- (void)removeViewAndHideHUD {
    [self.minimizeView removeFromSuperview];
    self.minimizeView = nil;
    [self.hud hideAnimated:YES];
    self.hud = nil;
}

- (void)saveViewAsImage:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (!image) {
        return;
    }
    if (DLBool(kDL_EnableShareMedia)) {
        [DLSaveMedia saveMediaOnCamera:image mediaType:1 needShare:YES];
    } else {
        [DLSaveMedia saveMediaOnCamera:image mediaType:1];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (totalBytesExpectedToWrite <= 0) {
        return;
    }
    float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    self.hud.label.text = [NSString stringWithFormat:@"%d%%", (int)(progress * 100)];
    self.minimizeView.percentLabel.text = self.hud.label.text;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSString *ext = @"dat";
    if (self.mediaType == 1) {
        ext = @"jpg";
    } else if (self.mediaType == 2) {
        ext = @"mp4";
    } else if (self.mediaType == 3) {
        ext = @"gif";
    } else if (self.mediaType == 4) {
        ext = @"m4a";
    }

    NSString *filename = [NSString stringWithFormat:@"DLMedia_%@.%@", @((long long)[[NSDate date] timeIntervalSince1970]), ext];
    NSString *destPath = [[[self class] documentsDirectoryPath] stringByAppendingPathComponent:filename];

    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:destPath error:nil];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:destPath] error:&error];
    if (error) {
        [DLHelper showAlertWithMessage:@"Failed to save file."];
        [self removeViewAndHideHUD];
        return;
    }
    [self didFinishDownloadingToPath:destPath];
}

- (void)didFinishDownloadingToPath:(id)path {
    if (!path) {
        [self removeViewAndHideHUD];
        return;
    }
    if (DLBool(kDL_EnableShareMedia)) {
        [DLSaveMedia saveMediaOnCamera:path mediaType:self.mediaType needShare:YES];
    } else {
        [DLSaveMedia saveMediaOnCamera:path mediaType:self.mediaType];
    }
    [self removeViewAndHideHUD];
}

- (void)executeCallback:(long long)code :(int)signal {
    (void)code;
    (void)signal;
}

@end
