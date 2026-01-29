#import "DLTapGestureRecognizer.h"

@interface DLTapGestureRecognizer ()
@property(copy, nonatomic) void (^onTabHandler)(void);
@end

@implementation DLTapGestureRecognizer

- (instancetype)initWithAction:(void (^)(void))action {
    self = [super initWithTarget:self action:@selector(didTabOnView:)];
    if (self) {
        self.onTabHandler = action;
    }
    return self;
}

- (void)didTabOnView:(id)sender {
    if (self.onTabHandler) {
        self.onTabHandler();
    }
}

@end
