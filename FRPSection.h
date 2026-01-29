#import <UIKit/UIKit.h>

@interface FRPSection : UITableViewCell

@property(retain, nonatomic) NSString *headerTitle;
@property(retain, nonatomic) NSString *footerTitle;
@property(retain, nonatomic) NSMutableArray *cells;
@property(retain, nonatomic) UIColor *tintUIColor;

+ (instancetype)sectionWithTitle:(id)title footer:(id)footer;
- (instancetype)initWithTitle:(id)title footer:(id)footer;
- (void)addCell:(id)cell;
- (void)addCells:(id)cells;
- (void)removeCell:(id)cell;

@end
