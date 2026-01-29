#import "FRPCell.h"
#import "FRPSettings.h"

@implementation FRPCell

+ (instancetype)cellWithTitle:(id)title setting:(id)setting {
    return [[self alloc] initWithTitle:title setting:setting];
}

- (instancetype)initWithTitle:(id)title setting:(id)setting {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    if (self) {
        self.title = title;
        self.setting = setting;
        self.textLabel.text = title;
        self.backgroundColor = [UIColor blackColor];
        self.contentView.backgroundColor = [UIColor blackColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.detailTextLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        if (@available(iOS 8.2, *)) {
            self.textLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightSemibold];
            self.detailTextLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightRegular];
        }
        self.height = 44;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)didSelectFromTable:(id)table {
    (void)table;
}

@end
