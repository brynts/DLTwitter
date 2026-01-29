#import "DLDownloaderMinimizeView.h"

@implementation DLDownloaderMinimizeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    self.layer.cornerRadius = 10.0;
    self.layer.masksToBounds = YES;
    self.percentLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.percentLabel.textAlignment = NSTextAlignmentCenter;
    self.percentLabel.font = [UIFont boldSystemFontOfSize:12.0];
    self.percentLabel.textColor = [UIColor whiteColor];
    self.percentLabel.text = @"0%";
    self.percentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.percentLabel];
}

@end
