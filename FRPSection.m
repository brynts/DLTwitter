#import "FRPSection.h"

@implementation FRPSection

+ (instancetype)sectionWithTitle:(id)title footer:(id)footer {
    return [[self alloc] initWithTitle:title footer:footer];
}

- (instancetype)initWithTitle:(id)title footer:(id)footer {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (self) {
        self.headerTitle = title;
        self.footerTitle = footer;
        self.cells = [NSMutableArray array];
    }
    return self;
}

- (void)addCell:(id)cell {
    if (cell) {
        [self.cells addObject:cell];
    }
}

- (void)addCells:(id)cells {
    if ([cells isKindOfClass:[NSArray class]]) {
        [self.cells addObjectsFromArray:cells];
    }
}

- (void)removeCell:(id)cell {
    if (cell) {
        [self.cells removeObject:cell];
    }
}

@end
