#import "FRPListCell.h"
#import "FRPSettings.h"
#import "FRPSelectListTable.h"

@implementation FRPListCell

+ (instancetype)cellWithTitle:(id)title setting:(id)setting items:(id)items value:(id)values popViewOnSelect:(BOOL)popView postNotification:(id)postNotification changedBlock:(void (^)(id))changedBlock {
    return [[self alloc] initWithTitle:title setting:setting items:items value:values popViewOnSelect:popView postNotification:postNotification changedBlock:changedBlock];
}

- (instancetype)initWithTitle:(id)title setting:(id)setting items:(id)items value:(id)values popViewOnSelect:(BOOL)popView postNotification:(id)postNotification changedBlock:(void (^)(id))changedBlock {
    self = [super initWithTitle:title setting:setting];
    if (self) {
        self.items = items;
        self.values = values;
        self.popView = popView;
        self.postNotification = postNotification;
        self.valueChanged = changedBlock;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.detailTextLabel.text = [self currentItemTitle];
    }
    return self;
}

- (NSString *)currentItemTitle {
    id current = [self.setting value];
    NSUInteger index = [self.values indexOfObject:current];
    if (index != NSNotFound && index < self.items.count) {
        return self.items[index];
    }
    return @"";
}

- (void)didSelectFromTable:(id)table {
    UITableViewController *vc = (UITableViewController *)table;
    FRPSelectListTable *list = [[FRPSelectListTable alloc] initWithStyle:UITableViewStyleGrouped title:self.title items:self.items values:self.values currentValue:[self.setting value] popViewOnSelect:self.popView changeBlock:^(id value) {
        [self.setting saveValue:value];
        self.detailTextLabel.text = [self currentItemTitle];
        if (self.valueChanged) {
            self.valueChanged(value);
        }
        if (self.postNotification) {
            [[NSNotificationCenter defaultCenter] postNotificationName:self.postNotification object:nil];
        }
    }];
    [vc.navigationController pushViewController:list animated:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.detailTextLabel.text = [self currentItemTitle];
}

@end
