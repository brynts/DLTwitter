#import <Foundation/Foundation.h>

@interface DLSaveMedia : NSObject

+ (void)clearCacheIfNeeded;
+ (void)showHUDInThreadWithState:(unsigned long long)state;
+ (void)saveMediaOnCamera:(id)media mediaType:(unsigned long long)type completion:(void (^)(BOOL success, NSError *error))completion;
+ (void)saveMediaOnCamera:(id)media mediaType:(unsigned long long)type;
+ (void)saveMediaOnCamera:(id)media mediaType:(unsigned long long)type showSuccess:(BOOL)showSuccess;
+ (void)saveMediaOnCamera:(id)media mediaType:(unsigned long long)type needShare:(BOOL)needShare;

@end
