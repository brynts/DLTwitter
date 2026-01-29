#import <Foundation/Foundation.h>

@interface DLMaxAlertAction : NSObject

@property(readonly, nonatomic) NSString *title;
@property(readonly, copy, nonatomic) void (^actionHandler)(void);

- (instancetype)initWithTitle:(id)title action:(void (^)(void))action;

@end
