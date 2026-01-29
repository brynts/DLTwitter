#import "FRPCell.h"

@interface FRPSegmentCell : FRPCell

@property(retain, nonatomic) UISegmentedControl *segment;
@property(retain, nonatomic) NSArray *values;
@property(retain, nonatomic) NSArray *displayedValues;

+ (instancetype)cellWithTitle:(id)title setting:(id)setting values:(id)values postNotification:(id)postNotification changeBlock:(void (^)(id value))changeBlock;
+ (instancetype)cellWithTitle:(id)title setting:(id)setting values:(id)values displayedValues:(id)displayedValues postNotification:(id)postNotification changeBlock:(void (^)(id value))changeBlock;
+ (instancetype)cellWithTitle:(id)title setting:(id)setting items:(id)items postNotification:(id)postNotification changeBlock:(void (^)(id value))changeBlock;
- (instancetype)initWithTitle:(id)title setting:(id)setting values:(id)values displayedValues:(id)displayedValues postNotification:(id)postNotification changeBlock:(void (^)(id value))changeBlock;
- (void)segmentAction:(id)sender;

@end
