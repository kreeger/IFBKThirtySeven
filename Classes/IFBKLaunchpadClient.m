#import "IFBKLaunchpadClient.h"
#import "IFBKLPModels.h"
#import "NSString+IFBKThirtySeven.h"

#import <AFNetworking/AFHTTPRequestOperation.h>
#import <AFNetworking/AFJSONRequestOperation.h>

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

@end

@implementation IFBKLaunchpadClient

@synthesize clientId = _clientId, clientSecret = _clientSecret, redirectUri = _redirectUri;

+ (instancetype)sharedInstance {
    static IFBKLaunchpadClient *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:@"https://launchpad.37signals.com/authorization"];
        __sharedInstance = [[IFBKLaunchpadClient alloc] initWithBaseURL:baseURL];
    });
    return __sharedInstance;
}

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
        [[self sharedInstance] setDefaultHeader:@"Authorization"
                                          value:[NSString stringWithFormat:@"Bearer %@", bearerToken]];
    } else {
        [[self sharedInstance] clearAuthorizationHeader];
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
    [[self sharedInstance] postPath:@"token"
                         parameters:params
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSString *accessToken = responseObject[@"access_token"];
                                [self setBearerToken:accessToken];
                                NSString *refreshToken = responseObject[@"refresh_token"];
                                NSTimeInterval interval = [responseObject[@"expires_in"] doubleValue];
                                NSDate *expiresAt = [[NSDate date] dateByAddingTimeInterval:interval];
                                success(accessToken, refreshToken, expiresAt);
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                failure(error, operation.response.statusCode);
                            }];
}

+ (void)refreshAccessTokenWithRefreshToken:(NSString *)refreshToken
                                   success:(TokenRefreshSuccessBlock)success
                                   failure:(FailureBlock)failure {
    NSDictionary *params = @{@"type": @"refresh",
                             @"refresh_token": refreshToken,
                             @"client_id": [[self sharedInstance] clientId],
                             @"client_secret": [[self sharedInstance] clientSecret]};
    // TODO: refactor this with getAccessToken... so long as this call works
    [[self sharedInstance] postPath:@"token"
                         parameters:params
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSString *accessToken = responseObject[@"access_token"];
                                [self setBearerToken:accessToken];
                                NSTimeInterval interval = [responseObject[@"expires_in"] doubleValue];
                                NSDate *expiresAt = [[NSDate date] dateByAddingTimeInterval:interval];
                                success(accessToken, expiresAt);
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                failure(error, operation.response.statusCode);
                            }];
}

+ (void)getAuthorizationData:(AuthDataBlock)success failure:(FailureBlock)failure {
    [[self sharedInstance] getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        IFBKLPAuthorizationData *authData = [IFBKLPAuthorizationData modelWithDictionary:responseObject];
        success(authData);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error, operation.response.statusCode);
    }];
}

@end
