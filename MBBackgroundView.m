#import "MBBackgroundView.h"

@implementation MBBackgroundView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _style = 0;
        _blurEffectStyle = UIBlurEffectStyleLight;
        _color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        [self updateForBackgroundStyle];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeZero;
}

- (void)updateViewsForColor:(id)color {
    if ([color isKindOfClass:[UIColor class]]) {
        self.backgroundColor = (UIColor *)color;
    }
}

- (void)updateForBackgroundStyle {
    if (_style == 1) {
        if (!self.effectView) {
            UIBlurEffect *effect = [UIBlurEffect effectWithStyle:(UIBlurEffectStyle)_blurEffectStyle];
            self.effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
            self.effectView.frame = self.bounds;
            self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self addSubview:self.effectView];
        }
        self.backgroundColor = UIColor.clearColor;
    } else {
        [self.effectView removeFromSuperview];
        self.effectView = nil;
        self.backgroundColor = self.color ?: [[UIColor blackColor] colorWithAlphaComponent:0.8];
    }
}

@end
