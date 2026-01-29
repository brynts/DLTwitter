#import "FRPreferences.h"
#import "FRPSection.h"
#import "FRPCell.h"

@implementation FRPreferences

+ (instancetype)tableWithSections:(id)sections title:(id)title tintColor:(id)tintColor {
    FRPreferences *table = [[FRPreferences alloc] initTableWithSections:sections];
    table.title = title;
    if ([tintColor isKindOfClass:[UIColor class]]) {
        table.tintUIColor = tintColor;
    }
    return table;
}

- (instancetype)initTableWithSections:(id)sections {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        if ([sections isKindOfClass:[NSArray class]]) {
            self.sections = sections;
        } else {
            self.sections = @[];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self updateTintColors];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateTintColors];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)updateTintColors {
    if (self.tintUIColor) {
        self.view.tintColor = self.tintUIColor;
    }
}

- (void)reloadTableView {
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    FRPSection *sec = self.sections[section];
    return sec.cells.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    FRPSection *sec = self.sections[section];
    return sec.headerTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    FRPSection *sec = self.sections[section];
    return sec.footerTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FRPCell *cell = [self cellForIndexPath:indexPath];
    return cell.height > 0 ? cell.height : 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self cellForIndexPath:indexPath];
}

- (id)cellForIndexPath:(id)indexPath {
    NSIndexPath *path = (NSIndexPath *)indexPath;
    FRPSection *sec = self.sections[path.section];
    return sec.cells[path.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FRPCell *cell = [self cellForIndexPath:indexPath];
    [cell didSelectFromTable:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    FRPSection *sec = self.sections[section];
    if (sec.headerTitle && [sec.headerTitle length] > 0) {
        return 28.0;
    }
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    FRPSection *sec = self.sections[section];
    if (!sec.headerTitle || [sec.headerTitle length] == 0) {
        return nil;
    }
    UIView *header = [[UIView alloc] initWithFrame:CGRectZero];
    header.backgroundColor = [UIColor blackColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = sec.headerTitle;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightSemibold];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:label];
    [NSLayoutConstraint activateConstraints:@[
        [label.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:16.0],
        [label.trailingAnchor constraintLessThanOrEqualToAnchor:header.trailingAnchor constant:-16.0],
        [label.bottomAnchor constraintEqualToAnchor:header.bottomAnchor constant:-4.0]
    ]];
    return header;
}

- (id)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    (void)tableView; (void)section;
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (![view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        view.backgroundColor = [UIColor blackColor];
        return;
    }
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor = [UIColor blackColor];
    header.textLabel.textColor = [UIColor whiteColor];
    header.textLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightSemibold];
    if (self.tintUIColor) {
        header.tintColor = self.tintUIColor;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    (void)tableView; (void)view; (void)section;
}

@end
