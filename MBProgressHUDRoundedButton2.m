#import "MBProgressHUDRoundedButton2.h"

@implementation MBProgressHUDRoundedButton2

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
    }
    return self;
}

@end
