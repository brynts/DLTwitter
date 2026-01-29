#import "MBProgressHUD.h"
#import "MBBackgroundView.h"

@interface MBProgressHUD ()
@property(nonatomic, strong) MBBackgroundView *bezelViewInternal;
@property(nonatomic, strong) MBBackgroundView *backgroundViewInternal;
@property(nonatomic, strong) UILabel *labelInternal;
@property(nonatomic, strong) UILabel *detailsLabelInternal;
@end

@implementation MBProgressHUD

+ (instancetype)HUDForView:(UIView *)view {
    if (!view) {
        return nil;
    }
    for (UIView *sub in view.subviews) {
        if ([sub isKindOfClass:[MBProgressHUD class]]) {
            return (MBProgressHUD *)sub;
        }
    }
    return nil;
}

+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated {
    MBProgressHUD *hud = [self HUDForView:view];
    if (!hud) {
        hud = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:hud];
    }
    [hud showAnimated:animated];
    return hud;
}

+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated {
    MBProgressHUD *hud = [self HUDForView:view];
    if (hud) {
        [hud hideAnimated:animated];
        return YES;
    }
    return NO;
}

- (instancetype)initWithView:(UIView *)view {
    self = [super initWithFrame:view.bounds];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        _removeFromSuperViewOnHide = YES;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundViewInternal = [[MBBackgroundView alloc] initWithFrame:self.bounds];
    self.backgroundViewInternal.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundViewInternal.style = 0;
    self.backgroundViewInternal.color = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [self addSubview:self.backgroundViewInternal];

    self.bezelViewInternal = [[MBBackgroundView alloc] initWithFrame:CGRectZero];
    self.bezelViewInternal.style = 0;
    self.bezelViewInternal.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    self.bezelViewInternal.layer.cornerRadius = 12.0;
    self.bezelViewInternal.layer.masksToBounds = YES;
    [self addSubview:self.bezelViewInternal];

    self.labelInternal = [[UILabel alloc] initWithFrame:CGRectZero];
    self.labelInternal.textColor = [UIColor whiteColor];
    self.labelInternal.font = [UIFont boldSystemFontOfSize:15.0];
    self.labelInternal.textAlignment = NSTextAlignmentCenter;
    self.labelInternal.numberOfLines = 0;
    [self.bezelViewInternal addSubview:self.labelInternal];

    self.detailsLabelInternal = [[UILabel alloc] initWithFrame:CGRectZero];
    self.detailsLabelInternal.textColor = [UIColor whiteColor];
    self.detailsLabelInternal.font = [UIFont systemFontOfSize:12.0];
    self.detailsLabelInternal.textAlignment = NSTextAlignmentCenter;
    self.detailsLabelInternal.numberOfLines = 0;
    [self.bezelViewInternal addSubview:self.detailsLabelInternal];
}

- (UILabel *)label { return self.labelInternal; }
- (UILabel *)detailsLabel { return self.detailsLabelInternal; }
- (MBBackgroundView *)bezelView { return self.bezelViewInternal; }
- (MBBackgroundView *)backgroundView { return self.backgroundViewInternal; }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat maxWidth = MIN(self.bounds.size.width - 40.0, 260.0);
    CGSize labelSize = [self.labelInternal sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
    CGSize detailsSize = [self.detailsLabelInternal sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
    CGFloat totalHeight = labelSize.height + (detailsSize.height > 0 ? (detailsSize.height + 6.0) : 0) + 30.0;
    CGFloat totalWidth = MAX(labelSize.width, detailsSize.width) + 40.0;
    CGRect bezelFrame = CGRectMake((self.bounds.size.width - totalWidth) / 2.0,
                                   (self.bounds.size.height - totalHeight) / 2.0,
                                   totalWidth,
                                   totalHeight);
    self.bezelViewInternal.frame = bezelFrame;
    self.labelInternal.frame = CGRectMake(20.0, 15.0, totalWidth - 40.0, labelSize.height);
    if (detailsSize.height > 0) {
        self.detailsLabelInternal.frame = CGRectMake(20.0, CGRectGetMaxY(self.labelInternal.frame) + 6.0, totalWidth - 40.0, detailsSize.height);
    } else {
        self.detailsLabelInternal.frame = CGRectZero;
    }
}

- (void)showAnimated:(BOOL)animated {
    if (animated) {
        self.alpha = 0.0;
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 1.0;
        }];
    } else {
        self.alpha = 1.0;
    }
}

- (void)hideAnimated:(BOOL)animated {
    void (^completion)(void) = ^{
        if (self.removeFromSuperViewOnHide) {
            [self removeFromSuperview];
        }
    };
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            completion();
        }];
    } else {
        completion();
    }
}

- (void)hideAnimated:(BOOL)animated afterDelay:(double)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideAnimated:animated];
    });
}

@end
