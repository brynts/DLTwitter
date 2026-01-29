#import "MBRoundProgressView.h"

@implementation MBRoundProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _progress = 0.0f;
        _progressTintColor = [UIColor whiteColor];
        _backgroundTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
        _annular = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(40.0, 40.0);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!ctx) {
        return;
    }
    CGFloat lineWidth = 2.0;
    CGRect circleRect = CGRectInset(rect, lineWidth, lineWidth);
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = startAngle + (2.0 * M_PI * MIN(MAX(self.progress, 0.0f), 1.0f));

    if (self.isAnnular) {
        CGContextSetStrokeColorWithColor(ctx, self.backgroundTintColor.CGColor);
        CGContextSetLineWidth(ctx, lineWidth);
        CGContextStrokeEllipseInRect(ctx, circleRect);

        CGContextSetStrokeColorWithColor(ctx, self.progressTintColor.CGColor);
        CGContextAddArc(ctx, CGRectGetMidX(rect), CGRectGetMidY(rect), circleRect.size.width / 2.0, startAngle, endAngle, 0);
        CGContextStrokePath(ctx);
    } else {
        CGContextSetFillColorWithColor(ctx, self.backgroundTintColor.CGColor);
        CGContextFillEllipseInRect(ctx, circleRect);

        CGContextSetFillColorWithColor(ctx, self.progressTintColor.CGColor);
        CGContextMoveToPoint(ctx, CGRectGetMidX(rect), CGRectGetMidY(rect));
        CGContextAddArc(ctx, CGRectGetMidX(rect), CGRectGetMidY(rect), circleRect.size.width / 2.0, startAngle, endAngle, 0);
        CGContextClosePath(ctx);
        CGContextFillPath(ctx);
    }
}

@end
