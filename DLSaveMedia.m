#import "DLSaveMedia.h"
#import <Photos/Photos.h>
#import "DLHelper.h"

static void DLPerformPhotoChanges(void (^changeBlock)(void), void (^completion)(BOOL success, NSError *error)) {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:changeBlock completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(success, error);
            }
        });
    }];
}

@implementation DLSaveMedia

+ (void)clearCacheIfNeeded {
    // Placeholder for cache cleanup; no-op for reconstruction.
}

+ (void)showHUDInThreadWithState:(unsigned long long)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        [DLHelper HUDWithState:state];
    });
}

+ (void)saveMediaOnCamera:(id)media mediaType:(unsigned long long)type completion:(void (^)(BOOL, NSError *))completion {
    if (type == 1 && [media isKindOfClass:[UIImage class]]) {
        UIImage *image = (UIImage *)media;
        UIImageWriteToSavedPhotosAlbum(image, nil, NULL, NULL);
        if (completion) {
            completion(YES, nil);
        }
        return;
    }

    NSURL *url = nil;
    if ([media isKindOfClass:[NSURL class]]) {
        url = (NSURL *)media;
    } else if ([media isKindOfClass:[NSString class]]) {
        url = [NSURL fileURLWithPath:(NSString *)media];
    }

    if (!url) {
        if (completion) {
            completion(NO, [NSError errorWithDomain:@"DLTwitter" code:-1 userInfo:nil]);
        }
        return;
    }

    DLPerformPhotoChanges(^{
        if (type == 2 || type == 4) {
            [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:url];
        } else {
            PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
            [request addResourceWithType:PHAssetResourceTypePhoto fileURL:url options:nil];
        }
    }, completion);
}

+ (void)saveMediaOnCamera:(id)media mediaType:(unsigned long long)type {
    [self saveMediaOnCamera:media mediaType:type completion:^(BOOL success, NSError *error) {
        [self showHUDInThreadWithState:success ? 1 : 2];
    }];
}

+ (void)saveMediaOnCamera:(id)media mediaType:(unsigned long long)type showSuccess:(BOOL)showSuccess {
    [self saveMediaOnCamera:media mediaType:type completion:^(BOOL success, NSError *error) {
        if (showSuccess) {
            [self showHUDInThreadWithState:success ? 1 : 2];
        }
    }];
}

+ (void)saveMediaOnCamera:(id)media mediaType:(unsigned long long)type needShare:(BOOL)needShare {
    [self saveMediaOnCamera:media mediaType:type completion:^(BOOL success, NSError *error) {
        if (!success) {
            [self showHUDInThreadWithState:2];
            return;
        }
        if (needShare) {
            [DLHelper showConfirmMessageSave:nil share:^{
                UIViewController *vc = [DLHelper topMostController];
                if (!vc) {
                    return;
                }
                NSArray *items = media ? @[media] : @[];
                UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
                [vc presentViewController:activity animated:YES completion:nil];
            }];
        } else {
            [self showHUDInThreadWithState:1];
        }
    }];
}

@end
