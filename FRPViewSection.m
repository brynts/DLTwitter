#import "FRPViewSection.h"
#import "FRPViewCell.h"

@implementation FRPViewSection

+ (instancetype)sectionWithHeight:(int)height initBlock:(void (^)(id))initBlock layoutBlock:(void (^)(UIView *))layoutBlock {
    return [[self alloc] initWithHeight:height initBlock:initBlock layoutBlock:layoutBlock];
}

- (id)initWithHeight:(int)height initBlock:(void (^)(id))initBlock layoutBlock:(void (^)(UIView *))layoutBlock {
    self = [super initWithTitle:nil footer:nil];
    if (self) {
        FRPViewCell *cell = [FRPViewCell cellWithHeight:height initBlock:initBlock layoutBlock:layoutBlock];
        [self addCell:cell];
    }
    return self;
}

@end
