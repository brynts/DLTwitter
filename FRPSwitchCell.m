#import "FRPSwitchCell.h"
#import "FRPSettings.h"

@implementation FRPSwitchCell

+ (instancetype)cellWithTitle:(id)title setting:(id)setting postNotification:(id)postNotification changeBlock:(void (^)(id))changeBlock {
    return [[self alloc] initWithTitle:title setting:setting postNotification:postNotification changeBlock:changeBlock];
}

- (instancetype)initWithTitle:(id)title setting:(id)setting postNotification:(id)postNotification changeBlock:(void (^)(id))changeBlock {
    self = [super initWithTitle:title setting:setting];
    if (self) {
        self.postNotification = postNotification;
        self.valueChanged = changeBlock;
        self.switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        BOOL on = [[self.setting value] boolValue];
        [self.switchView setOn:on];
        [self.switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = self.switchView;
    }
    return self;
}

- (void)switchChanged:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    [self.setting saveValue:@(sw.isOn)];
    if (self.valueChanged) {
        self.valueChanged(@(sw.isOn));
    }
    if (self.postNotification) {
        [[NSNotificationCenter defaultCenter] postNotificationName:self.postNotification object:nil];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
