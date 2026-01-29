#import "DLCrashViewController.h"

@interface DLCrashViewController ()
@property(nonatomic, strong) UITextView *textView;
@end

@implementation DLCrashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.editable = NO;
    self.textView.font = [UIFont systemFontOfSize:14.0];
    self.textView.text = self.crashMessage ?: @"An unexpected error occurred.";
    [self.view addSubview:self.textView];
}

@end
