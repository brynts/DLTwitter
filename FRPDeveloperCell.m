#import "FRPDeveloperCell.h"

@implementation FRPDeveloperCell

+ (instancetype)cellWithTitle:(id)title detail:(id)detail image:(id)image url:(id)url {
    return [[self alloc] initWithTitle:title detail:detail image:image url:url];
}

- (instancetype)initWithTitle:(id)title detail:(id)detail image:(id)image url:(id)url {
    self = [super initWithTitle:title setting:nil];
    if (self) {
        self.detailTextLabel.text = detail;
        self.imageView.image = image;
        self.url = url;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)didSelectFromTable:(id)table {
    (void)table;
    if (!self.url) {
        return;
    }
    NSURL *url = [NSURL URLWithString:self.url];
    if (!url) {
        return;
    }
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
