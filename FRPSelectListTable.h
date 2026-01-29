#import <UIKit/UIKit.h>

@interface FRPSelectListTable : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property(copy, nonatomic) void (^itemChanged)(id value);
@property(copy, nonatomic) UIColor *tintUIColor;

- (instancetype)initWithStyle:(long long)style title:(id)title items:(id)items values:(id)values currentValue:(id)currentValue popViewOnSelect:(BOOL)popView changeBlock:(void (^)(id value))changeBlock;

@end
