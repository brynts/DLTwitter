#import "DLSettingsButton.h"

@implementation DLSettingsButton

- (void)actionHandler:(void (^)(void))handler {
    self.action = handler;
    [self addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didPressButton:(id)sender {
    if (self.action) {
        self.action();
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.bounds.size.height / 2.0;
    self.layer.masksToBounds = YES;
}

@end
