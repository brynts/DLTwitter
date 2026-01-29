#import <Foundation/Foundation.h>

static NSString *const kDL_EnableDisableLoopVideo = @"DL_EnableDisableLoopVideo";
static NSString *const kDL_EnableOldVideoInterface = @"DL_EnableOldVideoInterface";
static NSString *const kDL_DisableNextVideo = @"DL_DisableNextVideo";
static NSString *const kDL_EnableConfirmFollow = @"DL_EnableConfirmFollow";
static NSString *const kDL_EnableConfirmLike_UnLike = @"DL_EnableConfirmLike_UnLike";
static NSString *const kDL_EnableTipJar = @"DL_EnableTipJar";
static NSString *const kDL_DisableTypingIndicatorInDM = @"DL_DisableTypingIndicatorInDM";
static NSString *const kDL_EnableBrowseAccountsBlockedYou = @"DL_EnableBrowseAccountsBlockedYou";
static NSString *const kDL_EnableOpenLinksInSafari = @"DL_EnableOpenLinksInSafari";
static NSString *const kDL_EnableAppLock = @"DL_EnableAppLock";
static NSString *const kDL_faceIdSaveDate = @"DL_faceIdSaveDate";
static NSString *const kDL_DelayAppLock = @"DL_DelayAppLock";
static NSString *const kDL_ProtectWithFaceId = @"DL_ProtectWithFaceId";
static NSString *const kDL_EnableCopyProfileInfo = @"DL_EnableCopyProfileInfo";
static NSString *const kDL_AlwyasShowTranslateTweet = @"DL_AlwyasShowTranslateTweet";
static NSString *const kDL_EnableAlwaysDLHighQuality = @"DL_EnableAlwaysDLHighQuality";
static NSString *const kDL_EnableRemoveAd = @"DL_EnableRemoveAd";
static NSString *const kDL_EnableVoiceInDM = @"DL_EnableVoiceInDM";
static NSString *const kDL_EnableVoiceTweet = @"DL_EnableVoiceTweet";
static NSString *const kDL_EnableShareMedia = @"DL_EnableShareMedia";

static inline NSUserDefaults *DLDefaults(void) {
    return [NSUserDefaults standardUserDefaults];
}

static inline BOOL DLBool(NSString *key) {
    return [DLDefaults() boolForKey:key];
}

static inline void DLSetBool(NSString *key, BOOL value) {
    [DLDefaults() setBool:value forKey:key];
    [DLDefaults() synchronize];
}

static inline id DLGetObject(NSString *key) {
    return [DLDefaults() objectForKey:key];
}

static inline void DLSetObject(NSString *key, id value) {
    if (value) {
        [DLDefaults() setObject:value forKey:key];
    } else {
        [DLDefaults() removeObjectForKey:key];
    }
    [DLDefaults() synchronize];
}
