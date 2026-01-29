#import "FRPViewCell.h"

@implementation FRPViewCell

+ (instancetype)cellWithHeight:(int)height initBlock:(void (^)(FRPViewCell *))initBlock layoutBlock:(void (^)(UIView *))layoutBlock {
    return [[self alloc] initWithHeight:height initBlock:initBlock layoutBlock:layoutBlock];
}

- (instancetype)initWithHeight:(int)height initBlock:(void (^)(FRPViewCell *))initBlock layoutBlock:(void (^)(UIView *))layoutBlock {
    self = [super initWithTitle:nil setting:nil];
    if (self) {
        (void)self.contentView;
        self.height = height;
        self.layoutBlock = layoutBlock;
        if (initBlock) {
            initBlock(self);
        }
    }
    return self;
}

- (void)addSubview:(UIView *)view {
    if (!view) {
        return;
    }
    // UITableViewCell internally adds its contentView via addSubview; avoid redirecting that.
    if (view == self.contentView || !self.contentView) {
        [super addSubview:view];
        return;
    }
    [self.contentView addSubview:view];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.layoutBlock) {
        self.layoutBlock(self.contentView);
    }
}

@end
