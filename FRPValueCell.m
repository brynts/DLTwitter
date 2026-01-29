#import "FRPValueCell.h"

@implementation FRPValueCell

+ (instancetype)cellWithTitle:(id)title detail:(id)detail {
    return [[self alloc] initWithTitle:title detail:detail];
}

- (instancetype)initWithTitle:(id)title detail:(id)detail {
    self = [super initWithTitle:title setting:nil];
    if (self) {
        self.detailTextLabel.text = detail;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
