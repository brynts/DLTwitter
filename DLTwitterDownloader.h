#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DLDownloaderMinimizeView, MBProgressHUD, NSURLSessionDownloadTask;

@protocol ExecuteDelegate <NSObject>
@end

@interface DLTwitterDownloader : NSObject <NSURLSessionDelegate, NSURLSessionDownloadDelegate, ExecuteDelegate>

@property(retain, nonatomic) MBProgressHUD *hud;
@property(retain, nonatomic) NSURLSessionDownloadTask *task;
@property(retain, nonatomic) DLDownloaderMinimizeView *minimizeView;
@property(nonatomic) unsigned long long mediaType;

+ (NSString *)documentsDirectoryPath;
- (void)downloadMediaURLString:(id)urlString mediaType:(unsigned long long)type;
- (void)saveViewAsImage:(UIView *)view;
- (void)cancel;
- (void)setupMinimizeView;
- (void)DLHUDHide;
- (void)whenHideHUD;
- (void)showHUDAgain;
- (void)removeViewAndHideHUD;
- (void)didFinishDownloadingToPath:(id)path;
- (void)executeCallback:(long long)code :(int)signal;

@end
