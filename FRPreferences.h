#import <UIKit/UIKit.h>

@interface FRPreferences : UITableViewController

@property(retain, nonatomic) NSArray *sections;
@property(retain, nonatomic) NSString *plistPath;
@property(retain, nonatomic) UIColor *tintUIColor;

+ (instancetype)tableWithSections:(id)sections title:(id)title tintColor:(id)tintColor;
- (instancetype)initTableWithSections:(id)sections;
- (void)reloadTableView;
- (id)cellForIndexPath:(id)indexPath;
- (void)updateTintColors;

@end
