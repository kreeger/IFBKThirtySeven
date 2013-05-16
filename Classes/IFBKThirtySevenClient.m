#import "IFBKThirtySevenClient.h"
#import <AFNetworking/AFJSONRequestOperation.h>

@implementation IFBKThirtySevenClient

#pragma mark - Initialization and singleton

- (id)initWithBaseURL:(NSURL *)url {
    if ((self = [super initWithBaseURL:url])) {
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setDefaultHeader:@"Accept-Language" value:@"en-us"];
        [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAPIReachabilityChanged object:nil];
        }];
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    }
    return self;
}

+ (NSString *)baseURL {
    return @"";
}

#pragma mark - Helpers

+ (void)cancelRequestsWithPrefix:(NSString *)prefix { }

@end
