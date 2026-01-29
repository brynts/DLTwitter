#import "DLMaxAlertViewController.h"
#import "DLMaxAlertAction.h"
#import "DLMaxAlertButton.h"
#import "DLMaxAlertTextView.h"
#import <objc/runtime.h>

@implementation DLMaxAlertViewController

- (instancetype)initWithTweakName:(id)tweakName message:(id)message actions:(id)actions {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.tweakName = tweakName;
        self.message = message;
        self.actions = actions;
        self.cornerRadius = 16.0;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];

    self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
    if (@available(iOS 13.0, *)) {
        self.containerView.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.containerView.backgroundColor = [UIColor whiteColor];
    }
    self.containerView.layer.cornerRadius = self.cornerRadius;
    self.containerView.layer.masksToBounds = YES;
    [self.view addSubview:self.containerView];

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = self.tweakName ?: @"";
    [self.containerView addSubview:self.titleLabel];

    self.bodyText = [[DLMaxAlertTextView alloc] initWithFrame:CGRectZero];
    self.bodyText.text = self.message ?: @"";
    [self.containerView addSubview:self.bodyText];

    UIStackView *stack = [[UIStackView alloc] initWithFrame:CGRectZero];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 8.0;
    [self.containerView addSubview:stack];

    for (DLMaxAlertAction *action in self.actions) {
        DLMaxAlertButton *button = [DLMaxAlertButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:action.title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(handleButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(button, @selector(handleButtonTap:), action, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [stack addArrangedSubview:button];
    }

    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.bodyText.translatesAutoresizingMaskIntoConstraints = NO;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [self.containerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.containerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.containerView.widthAnchor constraintLessThanOrEqualToConstant:320.0],
        [self.containerView.widthAnchor constraintGreaterThanOrEqualToConstant:260.0],

        [self.titleLabel.topAnchor constraintEqualToAnchor:self.containerView.topAnchor constant:16.0],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:16.0],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-16.0],

        [self.bodyText.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:8.0],
        [self.bodyText.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:12.0],
        [self.bodyText.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-12.0],
        [self.bodyText.heightAnchor constraintGreaterThanOrEqualToConstant:60.0],

        [stack.topAnchor constraintEqualToAnchor:self.bodyText.bottomAnchor constant:12.0],
        [stack.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:16.0],
        [stack.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-16.0],
        [stack.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor constant:-16.0]
    ]];
}

- (void)handleButtonTap:(UIButton *)sender {
    DLMaxAlertAction *action = objc_getAssociatedObject(sender, @selector(handleButtonTap:));
    if (action.actionHandler) {
        action.actionHandler();
    }
    [self dismissAlertController];
}

- (void)dismissAlertController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)applyCustomFontForBodyText {
    self.bodyText.font = [UIFont systemFontOfSize:14.0];
}

@end
