#import <UIKit/UIKit.h>

@class FRPSettings;

@interface FRPCell : UITableViewCell

@property(nonatomic) int height;
@property(retain, nonatomic) UIColor *tintUIColor;
@property(retain, nonatomic) FRPSettings *setting;
@property(retain, nonatomic) NSString *title;
@property(retain, nonatomic) NSString *postNotification;
@property(copy, nonatomic) void (^valueChanged)(id value);

+ (instancetype)cellWithTitle:(id)title setting:(id)setting;
- (instancetype)initWithTitle:(id)title setting:(id)setting;
- (void)didSelectFromTable:(id)table;

@end
