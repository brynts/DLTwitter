#import "FRPSegmentCell.h"
#import "FRPSettings.h"

@implementation FRPSegmentCell

+ (instancetype)cellWithTitle:(id)title setting:(id)setting values:(id)values postNotification:(id)postNotification changeBlock:(void (^)(id))changeBlock {
    return [self cellWithTitle:title setting:setting values:values displayedValues:values postNotification:postNotification changeBlock:changeBlock];
}

+ (instancetype)cellWithTitle:(id)title setting:(id)setting values:(id)values displayedValues:(id)displayedValues postNotification:(id)postNotification changeBlock:(void (^)(id))changeBlock {
    return [[self alloc] initWithTitle:title setting:setting values:values displayedValues:displayedValues postNotification:postNotification changeBlock:changeBlock];
}

+ (instancetype)cellWithTitle:(id)title setting:(id)setting items:(id)items postNotification:(id)postNotification changeBlock:(void (^)(id))changeBlock {
    return [[self alloc] initWithTitle:title setting:setting values:items displayedValues:items postNotification:postNotification changeBlock:changeBlock];
}

- (instancetype)initWithTitle:(id)title setting:(id)setting values:(id)values displayedValues:(id)displayedValues postNotification:(id)postNotification changeBlock:(void (^)(id))changeBlock {
    self = [super initWithTitle:title setting:setting];
    if (self) {
        self.values = values;
        self.displayedValues = displayedValues ?: values;
        self.postNotification = postNotification;
        self.valueChanged = changeBlock;

        self.segment = [[UISegmentedControl alloc] initWithItems:self.displayedValues];
        id current = [self.setting value];
        NSUInteger idx = [self.values indexOfObject:current];
        if (idx != NSNotFound) {
            self.segment.selectedSegmentIndex = idx;
        }
        [self.segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = self.segment;
    }
    return self;
}

- (void)segmentAction:(id)sender {
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    if (seg.selectedSegmentIndex < self.values.count) {
        id value = self.values[seg.selectedSegmentIndex];
        [self.setting saveValue:value];
        if (self.valueChanged) {
            self.valueChanged(value);
        }
        if (self.postNotification) {
            [[NSNotificationCenter defaultCenter] postNotificationName:self.postNotification object:nil];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
