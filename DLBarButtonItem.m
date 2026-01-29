#import "DLBarButtonItem.h"

@interface DLBarButtonItem ()
@property(copy, nonatomic) void (^onPressHandler)(void);
@end

@implementation DLBarButtonItem

- (instancetype)initWithTitle:(id)title style:(long long)style action:(void (^)(void))action {
    self = [super initWithTitle:title style:style target:self action:@selector(didPressBarButton:)];
    if (self) {
        self.onPressHandler = action;
    }
    return self;
}

- (instancetype)initWithImage:(id)image style:(long long)style action:(void (^)(void))action {
    self = [super initWithImage:image style:style target:self action:@selector(didPressBarButton:)];
    if (self) {
        self.onPressHandler = action;
    }
    return self;
}

- (void)didPressBarButton:(id)sender {
    if (self.onPressHandler) {
        self.onPressHandler();
    }
}

@end
