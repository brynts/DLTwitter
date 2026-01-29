#import "DLDebuggingVC.h"
#import <objc/runtime.h>

static NSString *const kDLDebugReuseId = @"myDebug";
static NSString *const kDLDebugKeyProperty = @"property";
static NSString *const kDLDebugKeyInfo = @"info";
static NSString *const kDLDebugHeaderToken = @"C:";
static NSString *const kDLDebugMethodToken = @"M:";
static NSString *const kDLDebugCheckOk = @"✓";
static NSString *const kDLDebugCheckFail = @"✕";
static NSString *const kDLDebugTitleOk = @"C: %@ [✓]";
static NSString *const kDLDebugTitleFail = @"C: %@ [✕]";
static NSString *const kDLDebugMethodFormat = @"%@M: %@";
static NSString *const kDLDebugNoError = @" [No Error] ";
static NSString *const kDLDebugAccessoryText = @"X";
static NSString *const kDLDebugCloseTitle = @"[close]";

static NSString *const kDLDebugClassInlineMedia = @"T1InlineMediaContainerView";
static NSString *const kDLDebugClassTimeline = @"THFHomeTimelineItemsViewController";
static NSString *const kDLDebugInfoDownloadButton = @"[DLDownload],[DownloadButton]";
static NSString *const kDLDebugInfoAlertInfo = @"[DLDownload],[AlertInfo]";

@interface DLDebuggingVC ()
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableDictionary *classDict;
@property(nonatomic, strong) NSMutableArray *displayList;
@property(nonatomic, strong) UILabel *emptyErrLabel;
@end

@implementation DLDebuggingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"DLDebugging";
    if (self.navigationController) {
        self.navigationController.navigationBar.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:kDLDebugCloseTitle
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismissDebugging)];

    self.classDict = [NSMutableDictionary dictionary];
    self.displayList = [NSMutableArray array];
    [self debuggingDLTwitter];
    [self.displayList addObjectsFromArray:self.classDict.allKeys];

    UITableView *table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    table.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    table.delegate = self;
    table.dataSource = self;
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:kDLDebugReuseId];
    table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView = table;
    [self.view addSubview:table];

    if (self.displayList.count == 0) {
        UILabel *empty = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height - 44.0) / 2.0,
                                                                   self.view.bounds.size.width, 44.0)];
        empty.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        empty.textAlignment = NSTextAlignmentCenter;
        empty.text = kDLDebugNoError;
        [self applyDebugBadgeStyleToLabel:empty text:kDLDebugNoError token:kDLDebugNoError];
        self.emptyErrLabel = empty;
        [self.view addSubview:empty];
    }
}

- (void)dismissDebugging {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    (void)tableView;
    return self.displayList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    (void)tableView;
    NSArray *values = self.classDict.allValues;
    if (section < 0 || section >= (NSInteger)values.count) {
        return 0;
    }
    NSDictionary *entry = values[section];
    NSArray *props = entry[kDLDebugKeyProperty];
    return props.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    (void)tableView;
    NSArray *keys = self.classDict.allKeys;
    if (section < 0 || section >= (NSInteger)keys.count) {
        return nil;
    }
    return keys[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDLDebugReuseId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kDLDebugReuseId];
    }

    NSDictionary *entry = self.classDict.allValues[indexPath.section];
    NSArray *props = entry[kDLDebugKeyProperty];
    NSString *text = (indexPath.row < (NSInteger)props.count) ? props[indexPath.row] : @"";
    NSString *info = entry[kDLDebugKeyInfo] ?: @"";

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.numberOfLines = 0;
    cell.backgroundColor = [[self debugAccentColor] colorWithAlphaComponent:0.15];

    UILabel *badge = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 24.0, 24.0)];
    badge.textAlignment = NSTextAlignmentCenter;
    badge.text = kDLDebugAccessoryText;
    badge.backgroundColor = [[self debugAccentColor] colorWithAlphaComponent:0.5];
    badge.textColor = [UIColor whiteColor];
    cell.accessoryView = badge;

    [self applyDebugBadgeStyleToLabel:cell.textLabel text:text token:kDLDebugMethodToken];
    cell.detailTextLabel.text = info;

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    (void)tableView;
    if (![view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        return;
    }
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [UIFont systemFontOfSize:15.0];
    NSString *text = header.textLabel.text ?: @"";
    UIColor *badgeColor = [self debugAccentColor];
    if ([text containsString:kDLDebugCheckOk]) {
        badgeColor = [UIColor colorWithRed:0.15 green:0.65 blue:0.25 alpha:1.0];
    } else if ([text containsString:kDLDebugCheckFail]) {
        badgeColor = [UIColor colorWithRed:0.80 green:0.18 blue:0.18 alpha:1.0];
    }

    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange tokenRange = [text rangeOfString:kDLDebugHeaderToken];
    if (tokenRange.location != NSNotFound) {
        NSDictionary *attrs = @{NSForegroundColorAttributeName: UIColor.whiteColor,
                                NSBackgroundColorAttributeName: badgeColor};
        [attr addAttributes:attrs range:tokenRange];
    }
    header.textLabel.attributedText = attr;
    header.textLabel.numberOfLines = 0;
}

- (UIColor *)debugAccentColor {
    return [UIColor colorWithRed:0.12 green:0.45 blue:0.82 alpha:1.0];
}

- (void)applyDebugBadgeStyleToLabel:(UILabel *)label text:(NSString *)text token:(NSString *)token {
    label.text = text;
    NSRange range = [text rangeOfString:token];
    if (range.location == NSNotFound) {
        return;
    }
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    NSDictionary *attrs = @{NSForegroundColorAttributeName: UIColor.whiteColor,
                            NSBackgroundColorAttributeName: [self debugAccentColor]};
    [attr addAttributes:attrs range:range];
    label.attributedText = attr;
}

- (void)debuggingDLTwitter {
    [self.classDict removeAllObjects];
    [self.displayList removeAllObjects];

    [self addDebugInfoForClassName:kDLDebugClassInlineMedia info:kDLDebugInfoDownloadButton];
    [self addDebugInfoForClassName:kDLDebugClassTimeline info:kDLDebugInfoAlertInfo];
}

- (void)addDebugInfoForClassName:(NSString *)className info:(NSString *)info {
    Class cls = NSClassFromString(className);
    if (!cls) {
        NSString *title = [NSString stringWithFormat:kDLDebugTitleFail, className];
        self.classDict[title] = @{};
        return;
    }

    NSMutableArray *items = [NSMutableArray array];
    [self addMethodInfoForClass:cls selector:@selector(init) prefix:@"-" toArray:items];
    [self addMethodInfoForClass:cls selector:@selector(init) prefix:@"+" toArray:items classMethod:YES];
    [self addMethodInfoForClass:cls selector:@selector(viewDidLoad) prefix:@"-" toArray:items];
    [self addMethodInfoForClass:cls selector:@selector(viewDidLoad) prefix:@"+" toArray:items classMethod:YES];

    NSString *title = [NSString stringWithFormat:kDLDebugTitleOk, className];
    self.classDict[title] = @{kDLDebugKeyProperty: items, kDLDebugKeyInfo: info ?: @""};
}

- (void)addMethodInfoForClass:(Class)cls selector:(SEL)sel prefix:(NSString *)prefix toArray:(NSMutableArray *)items {
    [self addMethodInfoForClass:cls selector:sel prefix:prefix toArray:items classMethod:NO];
}

- (void)addMethodInfoForClass:(Class)cls selector:(SEL)sel prefix:(NSString *)prefix toArray:(NSMutableArray *)items classMethod:(BOOL)isClass {
    Method method = isClass ? class_getClassMethod(cls, sel) : class_getInstanceMethod(cls, sel);
    if (!method) {
        return;
    }
    NSString *selName = NSStringFromSelector(sel);
    NSString *entry = [NSString stringWithFormat:kDLDebugMethodFormat, prefix, selName];
    [items addObject:entry];
}

@end
