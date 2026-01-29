#import "FRPLinkCell.h"

@interface FRPLinkCell ()
@property(copy, nonatomic) void (^selectedBlock)(void);
@end

@implementation FRPLinkCell

+ (instancetype)cellWithTitle:(id)title selectedBlock:(void (^)(void))block {
    return [[self alloc] initWithTitle:title selectedBlock:block];
}

- (instancetype)initWithTitle:(id)title selectedBlock:(void (^)(void))block {
    self = [super initWithTitle:title setting:nil];
    if (self) {
        self.selectedBlock = block;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)didSelectFromTable:(id)table {
    (void)table;
    if (self.selectedBlock) {
        self.selectedBlock();
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
