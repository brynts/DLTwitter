#import "DLPreferencesNavigationController.h"

@implementation DLPreferencesNavigationController

+ (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    return [[self alloc] initWithRootViewController:rootViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.prefersLargeTitles = NO;
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    self.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
}

@end
