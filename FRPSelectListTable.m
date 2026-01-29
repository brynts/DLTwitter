#import "FRPSelectListTable.h"

@interface FRPSelectListTable ()
@property(retain, nonatomic) NSArray *listItems;
@property(retain, nonatomic) NSArray *listValues;
@property(retain, nonatomic) id currentValue;
@property(nonatomic) BOOL popView;
@end

@implementation FRPSelectListTable

- (instancetype)initWithStyle:(long long)style title:(id)title items:(id)items values:(id)values currentValue:(id)currentValue popViewOnSelect:(BOOL)popView changeBlock:(void (^)(id))changeBlock {
    self = [super initWithStyle:style];
    if (self) {
        self.title = title;
        self.listItems = items ?: @[];
        self.listValues = values ?: @[];
        self.currentValue = currentValue;
        self.popView = popView;
        self.itemChanged = changeBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.tintUIColor) {
        self.view.tintColor = self.tintUIColor;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FRPSelectListCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FRPSelectListCell"];
    }
    cell.textLabel.text = self.listItems[indexPath.row];
    id value = self.listValues[indexPath.row];
    cell.accessoryType = ([value isEqual:self.currentValue]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentValue = self.listValues[indexPath.row];
    if (self.itemChanged) {
        self.itemChanged(self.currentValue);
    }
    [tableView reloadData];
    if (self.popView) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
