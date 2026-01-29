#import "FRPCell.h"

@interface FRPTextFieldCell : FRPCell <UITextFieldDelegate>

@property(retain, nonatomic) UITextField *textField;
+ (instancetype)cellWithTitle:(id)title setting:(id)setting placeholder:(id)placeholder postNotification:(id)postNotification changeBlock:(void (^)(id value))changeBlock;
- (instancetype)initWithTitle:(id)title setting:(id)setting placeholder:(id)placeholder postNotification:(id)postNotification changeBlock:(void (^)(id value))changeBlock;
- (void)textFieldChanged:(id)sender;

@end
