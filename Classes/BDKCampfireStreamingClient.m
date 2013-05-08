#import "BDKCampfireStreamingClient.h"
#import "BDKCFMessage.h"

#import <AFNetworking/AFHTTPRequestOperation.h>
#import <AFNetworking/AFJSONRequestOperation.h>
#import "NSString+BDKThirtySeven.h"

#define kBDKCampfireBaseStreamingURL @"https://streaming.campfirenow.com"

@interface BDKCampfireStreamingClient ()

@end

@implementation BDKCampfireStreamingClient

- (id)initWithBaseURL:(NSURL *)url accessToken:(NSString *)accessToken {
    if (self = [super initWithBaseURL:url]) {
        [self setBearerToken:accessToken];
        // [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    }
    return self;
}

- (void)cancelRequestsWithPrefix:(NSString *)prefix {
    NSString *requestMatch = [NSString stringWithFormat:@"%@%@", [self baseURL], prefix];
    for (AFHTTPRequestOperation *operation in [self.operationQueue operations]) {
        if ([[[operation.request URL] description] hasPrefix:requestMatch]) [operation cancel];
    }
}

- (void)setBearerToken:(NSString *)bearerToken {
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", bearerToken]];
}

- (void)streamMessagesForRoom:(NSNumber *)roomId success:(EmptyBlock)success failure:(FailureBlock)failure {
    
}

@end
