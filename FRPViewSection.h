#import "FRPSection.h"

@interface FRPViewSection : FRPSection

@property(copy, nonatomic) void (^cellBlock)(FRPViewSection *section);
+ (instancetype)sectionWithHeight:(int)height initBlock:(void (^)(id cell))initBlock layoutBlock:(void (^)(UIView *contentView))layoutBlock;
- (id)initWithHeight:(int)height initBlock:(void (^)(id cell))initBlock layoutBlock:(void (^)(UIView *contentView))layoutBlock;

@end
