#import <Foundation/Foundation.h>

@interface FRPSettings : NSObject

@property(retain, nonatomic) NSString *key;
@property(retain, nonatomic) NSString *fileSave;
@property(copy, nonatomic) void (^valueDidChangeBlock)(id value);
@property(retain, nonatomic) id value;

+ (instancetype)settingsWithKey:(id)key defaultValue:(id)defaultValue;
- (instancetype)initWithKey:(id)key defaultValue:(id)defaultValue;
- (void)saveValue:(id)value;

@end
