#import "FRPCell.h"

@interface FRPViewCell : FRPCell

@property(nonatomic) BOOL hideSeperators;
@property(copy, nonatomic) void (^layoutBlock)(UIView *contentView);

+ (instancetype)cellWithHeight:(int)height initBlock:(void (^)(FRPViewCell *cell))initBlock layoutBlock:(void (^)(UIView *contentView))layoutBlock;
- (instancetype)initWithHeight:(int)height initBlock:(void (^)(FRPViewCell *cell))initBlock layoutBlock:(void (^)(UIView *contentView))layoutBlock;

@end
