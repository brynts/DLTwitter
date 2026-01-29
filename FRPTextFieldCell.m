#import "FRPTextFieldCell.h"
#import "FRPSettings.h"

@implementation FRPTextFieldCell

+ (instancetype)cellWithTitle:(id)title setting:(id)setting placeholder:(id)placeholder postNotification:(id)postNotification changeBlock:(void (^)(id))changeBlock {
    return [[self alloc] initWithTitle:title setting:setting placeholder:placeholder postNotification:postNotification changeBlock:changeBlock];
}

- (instancetype)initWithTitle:(id)title setting:(id)setting placeholder:(id)placeholder postNotification:(id)postNotification changeBlock:(void (^)(id))changeBlock {
    self = [super initWithTitle:title setting:setting];
    if (self) {
        self.postNotification = postNotification;
        self.valueChanged = changeBlock;
        self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
        self.textField.placeholder = placeholder;
        self.textField.delegate = self;
        self.textField.text = [self.setting value];
        [self.textField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        self.textField.textAlignment = NSTextAlignmentRight;
        self.accessoryView = self.textField;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textField.frame = CGRectMake(0, 0, 160, 30);
}

- (void)textFieldChanged:(id)sender {
    UITextField *field = (UITextField *)sender;
    [self.setting saveValue:field.text];
    if (self.valueChanged) {
        self.valueChanged(field.text);
    }
    if (self.postNotification) {
        [[NSNotificationCenter defaultCenter] postNotificationName:self.postNotification object:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
