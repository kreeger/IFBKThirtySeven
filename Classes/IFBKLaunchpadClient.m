#import "IFBKLaunchpadClient.h"
#import "IFBKLPModels.h"
#import "NSString+IFBKThirtySeven.h"

#import <AFNetworking/AFHTTPRequestOperation.h>
//#import <AFNetworking/AFJSONRequestOperation.h>

#define kIFBKLaunchpadURL @"https://launchpad.37signals.com/authorization/new?type=web_server&client_id=%@&redirect_uri=%@"

@interface IFBKLaunchpadClient ()

/**
 This application's OAuth client ID.
 */
@property (strong, nonatomic) NSString *clientId;
/**
 This application's OAuth client secret key.
 */
@property (strong, nonatomic) NSString *clientSecret;
/**
 This application's OAuth redirect URI, which is passed in as a post-authentication callback.
 */
@property (strong, nonatomic) NSString *redirectUri;

+ (void)handleSuccessfulAuthorization:(AFHTTPRequestOperation *)operation
                           withObject:(id)responseObject
                           completion:(TokenSuccessBlock)completion;

@end

@implementation IFBKLaunchpadClient

@synthesize clientId = _clientId, clientSecret = _clientSecret, redirectUri = _redirectUri;

#pragma mark - Lifecycle

+ (instancetype)sharedInstance {
    static IFBKLaunchpadClient *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:@"https://launchpad.37signals.com"];
        __sharedInstance = [[IFBKLaunchpadClient alloc] initWithBaseURL:baseURL];
    });
    return __sharedInstance;
}

#pragma mark - Private methods

+ (void)handleSuccessfulAuthorization:(AFHTTPRequestOperation *)operation
                           withObject:(id)responseObject
                           completion:(TokenSuccessBlock)completion {
    NSString *accessToken = responseObject[@"access_token"];
    [self setBearerToken:accessToken];
    NSString *refreshToken = responseObject[@"refresh_token"];
    NSTimeInterval interval = [responseObject[@"expires_in"] doubleValue];
    NSDate *expiresAt = [[NSDate date] dateByAddingTimeInterval:interval];
    if (completion) {
        completion(accessToken, refreshToken, expiresAt);
    }
}

#pragma mark - Methods

+ (void)setClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret redirectUri:(NSString *)redirectUri {
    [[self sharedInstance] setClientId:clientId];
    [[self sharedInstance] setClientSecret:clientSecret];
    [[self sharedInstance] setRedirectUri:redirectUri];
}

+ (NSURL *)launchpadURL {
    NSString *clientID = [[self sharedInstance] clientId];
    NSString *redirectURI = [[self sharedInstance] redirectUri];
    return [NSURL URLWithString:[NSString stringWithFormat:kIFBKLaunchpadURL, clientID, redirectURI]];
}

+ (void)setBearerToken:(NSString *)bearerToken {
    if (bearerToken && ![bearerToken isEqualToString:@""]) {
        [[[self sharedInstance] requestSerializer] setValue:[NSString stringWithFormat:@"Bearer %@", bearerToken]
                                         forHTTPHeaderField:@"Authorization"];
    } else {
        [[[self sharedInstance] requestSerializer] clearAuthorizationHeader];
    }
}

+ (void)getAccessTokenForVerificationCode:(NSString *)verificationCode
                                  success:(TokenSuccessBlock)success
                                  failure:(FailureBlock)failure {
    NSDictionary *params = @{@"type": @"web_server",
                             @"client_id": [[self sharedInstance] clientId],
                             @"redirect_uri": [[self sharedInstance] redirectUri],
                             @"client_secret": [[self sharedInstance] clientSecret],
                             @"code": [verificationCode stringByUrlEncoding]};

    [[self sharedInstance] POST:@"authorization/token"
                     parameters:params
                        success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self handleSuccessfulAuthorization:operation
                                  withObject:responseObject
                                  completion:success];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         failure(error, operation.response);
     }];
}

+ (void)refreshAccessTokenWithRefreshToken:(NSString *)refreshToken
                                   success:(TokenRefreshSuccessBlock)success
                                   failure:(FailureBlock)failure {
    NSDictionary *params = @{@"type": @"refresh",
                             @"refresh_token": refreshToken,
                             @"client_id": [[self sharedInstance] clientId],
                             @"client_secret": [[self sharedInstance] clientSecret]};
    [[self sharedInstance] POST:@"authorization/token"
                     parameters:params
                        success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self handleSuccessfulAuthorization:operation
                                  withObject:responseObject
                                  completion:^(NSString *accessToken, NSString *innerRefreshToken, NSDate *expiresAt) {
                                      if (success) {
                                          success(accessToken, expiresAt);
                                      }
                                  }];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         failure(error, operation.response);
     }];
}

+ (void)getAuthorizationData:(AuthDataBlock)success failure:(FailureBlock)failure {
    [[self sharedInstance] GET:@"authorization.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        IFBKLPAuthorizationData *authData = [IFBKLPAuthorizationData modelWithDictionary:responseObject];
        success(authData);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error, operation.response);
    }];
}

@end
