#import "NSString+BDKThirtySeven.h"

@implementation NSString (BDKThirtySeven)

- (BOOL)isEmptyOrNull {
    return self == nil || [(NSNull *)self isEqual:[NSNull null]] || [self isEqual:@""];
}

- (NSURL *)urlValue {
    return [NSURL URLWithString:self];
}

- (NSString *)stringByUrlEncoding {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'();:@&amp;=+$,/?%#[]", kCFStringEncodingUTF8));
}

@end
