#import <UIKit/UIKit.h>

@interface DLTwitterViewCell : UIView

@property(retain, nonatomic) UIView *contentView;
@property(retain, nonatomic) UIView *separatorLineView;
@property(retain, nonatomic) UIView *viewCell;
@property(retain, nonatomic) UIImageView *imageView;
@property(retain, nonatomic) UILabel *titleLabel;

- (void)didTabAction:(void (^)(void))handler;
- (void)didTabOnView:(id)sender;
- (void)setupViews;
- (void)updateColorIfNeeded;
- (void)changeColorByProgress:(double)progress;
- (void)animateColorWithType:(unsigned long long)type;

@end
