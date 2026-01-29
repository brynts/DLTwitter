#import "DLMaxAlertButton.h"

@implementation DLMaxAlertButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [self setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    }
    return self;
}

@end
