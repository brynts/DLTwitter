#import "DLButton.h"

@implementation DLButton

- (void)actionHandler:(void (^)(void))handler {
    self.action = handler;
    [self addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didPressButton:(id)sender {
    if (self.action) {
        self.action();
    }
}

@end
