#import "FRPCell.h"

@interface FRPLinkCell : FRPCell
+ (instancetype)cellWithTitle:(id)title selectedBlock:(void (^)(void))block;
- (instancetype)initWithTitle:(id)title selectedBlock:(void (^)(void))block;
@end
