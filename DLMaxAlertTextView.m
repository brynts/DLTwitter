#import "DLMaxAlertTextView.h"

@implementation DLMaxAlertTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.editable = NO;
        self.scrollEnabled = YES;
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont systemFontOfSize:14.0];
    }
    return self;
}

@end
