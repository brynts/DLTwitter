#import "MBBarProgressView.h"

@implementation MBBarProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _progress = 0.0f;
        _lineColor = [UIColor whiteColor];
        _progressRemainingColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
        _progressColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(120.0, 10.0);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!ctx) {
        return;
    }
    CGRect lineRect = CGRectInset(rect, 1.0, 1.0);
    CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor);
    CGContextStrokeRectWithWidth(ctx, lineRect, 1.0);

    CGFloat progressWidth = lineRect.size.width * MIN(MAX(self.progress, 0.0f), 1.0f);
    CGRect progressRect = CGRectMake(lineRect.origin.x, lineRect.origin.y, progressWidth, lineRect.size.height);
    CGContextSetFillColorWithColor(ctx, self.progressColor.CGColor);
    CGContextFillRect(ctx, progressRect);

    if (progressWidth < lineRect.size.width) {
        CGRect remainRect = CGRectMake(CGRectGetMaxX(progressRect), lineRect.origin.y, lineRect.size.width - progressWidth, lineRect.size.height);
        CGContextSetFillColorWithColor(ctx, self.progressRemainingColor.CGColor);
        CGContextFillRect(ctx, remainRect);
    }
}

@end
