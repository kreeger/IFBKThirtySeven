#import "BDKThirtySevenClient.h"

@implementation BDKThirtySevenClient

#pragma mark - Initialization and singleton

- (id)initWithBaseURL:(NSURL *)url {
    if ((self = [super initWithBaseURL:url])) {
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setDefaultHeader:@"Accept-Language" value:@"en-us"];
        [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAPIReachabilityChanged object:nil];
        }];
    }
    return self;
}

+ (NSString *)baseURL {
    return @"";
}

#pragma mark - Helpers

+ (void)cancelRequestsWithPrefix:(NSString *)prefix { }

@end
