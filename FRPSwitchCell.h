#import "FRPCell.h"

@class UISwitch;

@interface FRPSwitchCell : FRPCell

@property(retain, nonatomic) UISwitch *switchView;
+ (instancetype)cellWithTitle:(id)title setting:(id)setting postNotification:(id)postNotification changeBlock:(void (^)(id value))changeBlock;
- (instancetype)initWithTitle:(id)title setting:(id)setting postNotification:(id)postNotification changeBlock:(void (^)(id value))changeBlock;
- (void)switchChanged:(id)sender;

@end
