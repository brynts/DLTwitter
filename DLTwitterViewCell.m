#import "DLTwitterViewCell.h"

@interface DLTwitterViewCell ()
@property(copy, nonatomic) void (^onTabHandler)(void);
@end

@implementation DLTwitterViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.contentView = [[UIView alloc] initWithFrame:self.bounds];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.contentView];

    self.viewCell = [[UIView alloc] initWithFrame:self.contentView.bounds];
    self.viewCell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:self.viewCell];

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.viewCell addSubview:self.imageView];

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
    [self.viewCell addSubview:self.titleLabel];

    self.separatorLineView = [[UIView alloc] initWithFrame:CGRectZero];
    self.separatorLineView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    [self.viewCell addSubview:self.separatorLineView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat padding = 12.0;
    CGFloat iconSize = 22.0;
    self.imageView.frame = CGRectMake(padding, (self.bounds.size.height - iconSize) / 2.0, iconSize, iconSize);
    CGFloat labelX = CGRectGetMaxX(self.imageView.frame) + 10.0;
    self.titleLabel.frame = CGRectMake(labelX, 0, self.bounds.size.width - labelX - padding, self.bounds.size.height);
    self.separatorLineView.frame = CGRectMake(padding, self.bounds.size.height - 1.0, self.bounds.size.width - padding, 1.0);
}

- (void)didTabAction:(void (^)(void))handler {
    self.onTabHandler = handler;
}

- (void)didTabOnView:(id)sender {
    if (self.onTabHandler) {
        self.onTabHandler();
    }
}

- (void)updateColorIfNeeded {
    self.backgroundColor = [UIColor clearColor];
}

- (void)changeColorByProgress:(double)progress {
    CGFloat alpha = MIN(MAX(progress, 0.0), 1.0) * 0.15;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:alpha];
}

- (void)animateColorWithType:(unsigned long long)type {
    if (type == 0) {
        [UIView animateWithDuration:0.2 animations:^{
            [self changeColorByProgress:1.0];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                [self changeColorByProgress:0.0];
            }];
        }];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self changeColorByProgress:1.0];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self changeColorByProgress:0.0];
    [self didTabOnView:self];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self changeColorByProgress:0.0];
}

@end
