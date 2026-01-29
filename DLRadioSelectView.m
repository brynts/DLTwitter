#import "DLRadioSelectView.h"
#import "DLHelper.h"

@implementation DLRadioSelectView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.checkedImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.checkedImageView.contentMode = UIViewContentModeCenter;
        self.checkedImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.checkedImageView.image = [DLHelper imageIcon:@"checkmark_24pt"]; 
        [self addSubview:self.checkedImageView];
        self.checked = NO;
    }
    return self;
}

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    self.checkedImageView.hidden = !checked;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.checkedImageView.frame = self.bounds;
}

@end
