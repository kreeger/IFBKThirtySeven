#import "IFBKThirtySevenClient.h"

@implementation IFBKThirtySevenClient

#pragma mark - Initialization and singleton

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) return nil;

    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.requestSerializer setValue:@"en-us" forHTTPHeaderField:@"Accept-Language"];
    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAPIReachabilityChanged object:nil];
    }];

    return self;
}

+ (NSString *)baseURL {
    return @"";
}

#pragma mark - Helpers

+ (void)cancelRequestsWithPrefix:(NSString *)prefix { }

@end
