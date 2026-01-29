#import "MBProgressHUDRoundedButton.h"

@implementation MBProgressHUDRoundedButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 6.0;
        self.layer.masksToBounds = YES;
    }
    return self;
}

@end
