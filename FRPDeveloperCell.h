#import "FRPCell.h"

@interface FRPDeveloperCell : FRPCell

@property(retain, nonatomic) NSString *url;
@property(retain, nonatomic) UIImage *image;

+ (instancetype)cellWithTitle:(id)title detail:(id)detail image:(id)image url:(id)url;
- (instancetype)initWithTitle:(id)title detail:(id)detail image:(id)image url:(id)url;

@end
