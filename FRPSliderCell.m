#import "FRPSliderCell.h"
#import "FRPSettings.h"

@implementation FRPSliderCell

+ (instancetype)cellWithTitle:(id)title setting:(id)setting min:(float)min max:(float)max postNotification:(id)postNotification changeBlock:(void (^)(id))changeBlock {
    return [[self alloc] initWithTitle:title setting:setting min:min max:max postNotification:postNotification changeBlock:changeBlock];
}

- (instancetype)initWithTitle:(id)title setting:(id)setting min:(float)min max:(float)max postNotification:(id)postNotification changeBlock:(void (^)(id))changeBlock {
    self = [super initWithTitle:title setting:setting];
    if (self) {
        self.min = min;
        self.max = max;
        self.postNotification = postNotification;
        self.valueChanged = changeBlock;

        self.sliderCell = [[UISlider alloc] initWithFrame:CGRectZero];
        self.sliderCell.minimumValue = min;
        self.sliderCell.maximumValue = max;
        self.sliderCell.value = [[self.setting value] floatValue];
        [self.sliderCell addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.sliderCell];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat padding = 15.0;
    self.sliderCell.frame = CGRectMake(padding, 28.0, self.contentView.bounds.size.width - padding * 2, 20.0);
}

- (void)sliderChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    [self.setting saveValue:@(slider.value)];
    if (self.valueChanged) {
        self.valueChanged(@(slider.value));
    }
    if (self.postNotification) {
        [[NSNotificationCenter defaultCenter] postNotificationName:self.postNotification object:nil];
    }
}

@end
