#import "FRPCell.h"

@interface FRPListCell : FRPCell

@property(nonatomic) BOOL popView;
@property(retain, nonatomic) NSArray *items;
@property(retain, nonatomic) NSArray *values;

+ (instancetype)cellWithTitle:(id)title setting:(id)setting items:(id)items value:(id)values popViewOnSelect:(BOOL)popView postNotification:(id)postNotification changedBlock:(void (^)(id value))changedBlock;
- (instancetype)initWithTitle:(id)title setting:(id)setting items:(id)items value:(id)values popViewOnSelect:(BOOL)popView postNotification:(id)postNotification changedBlock:(void (^)(id value))changedBlock;

@end
