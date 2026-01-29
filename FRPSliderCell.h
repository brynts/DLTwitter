#import "FRPCell.h"

@class UILabel, UISlider;

@interface FRPSliderCell : FRPCell

@property(nonatomic) float min;
@property(nonatomic) float max;
@property(retain, nonatomic) UISlider *sliderCell;
@property(retain, nonatomic) UILabel *lLabel;
@property(retain, nonatomic) UILabel *rLabel;
@property(retain, nonatomic) UILabel *cLabel;
@property(retain, nonatomic) UILabel *vLabel;

+ (instancetype)cellWithTitle:(id)title setting:(id)setting min:(float)min max:(float)max postNotification:(id)postNotification changeBlock:(void (^)(id value))changeBlock;
- (instancetype)initWithTitle:(id)title setting:(id)setting min:(float)min max:(float)max postNotification:(id)postNotification changeBlock:(void (^)(id value))changeBlock;
- (void)sliderChanged:(id)sender;

@end
