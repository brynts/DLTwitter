#import "FRPCell.h"

@interface FRPValueCell : FRPCell
+ (instancetype)cellWithTitle:(id)title detail:(id)detail;
- (instancetype)initWithTitle:(id)title detail:(id)detail;
@end
