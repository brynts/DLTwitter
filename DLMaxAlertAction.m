#import "DLMaxAlertAction.h"

@implementation DLMaxAlertAction

- (instancetype)initWithTitle:(id)title action:(void (^)(void))action {
    self = [super init];
    if (self) {
        _title = [title copy];
        _actionHandler = [action copy];
    }
    return self;
}

@end
