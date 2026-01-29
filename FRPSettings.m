#import "FRPSettings.h"
#import "DLPrefs.h"

@implementation FRPSettings

+ (instancetype)settingsWithKey:(id)key defaultValue:(id)defaultValue {
    return [[self alloc] initWithKey:key defaultValue:defaultValue];
}

- (instancetype)initWithKey:(id)key defaultValue:(id)defaultValue {
    self = [super init];
    if (self) {
        self.key = key;
        if (key && ![DLDefaults() objectForKey:key]) {
            if (defaultValue) {
                [DLDefaults() setObject:defaultValue forKey:key];
                [DLDefaults() synchronize];
            }
        }
    }
    return self;
}

- (id)value {
    if (!self.key) {
        return nil;
    }
    return [DLDefaults() objectForKey:self.key];
}

- (void)setValue:(id)value {
    [self saveValue:value];
}

- (void)saveValue:(id)value {
    if (!self.key) {
        return;
    }
    if (value) {
        [DLDefaults() setObject:value forKey:self.key];
    } else {
        [DLDefaults() removeObjectForKey:self.key];
    }
    [DLDefaults() synchronize];
    if (self.valueDidChangeBlock) {
        self.valueDidChangeBlock(value);
    }
}

- (void)observeValueForKeyPath:(id)keyPath ofObject:(id)object change:(id)change context:(void *)context {
    (void)keyPath; (void)object; (void)change; (void)context;
}

@end
