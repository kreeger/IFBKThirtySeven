#import "BDKLaunchpadClient.h"
#import "BDKLPModels.h"
#import "NSString+BDKThirtySeven.h"

#import <AFNetworking/AFHTTPRequestOperation.h>
#import <AFNetworking/AFJSONRequestOperation.h>

#define kBDKLaunchpadURL @"https://launchpad.37signals.com/authorization/new?type=web_server&client_id=%@&redirect_uri=%@"

@interface BDKLaunchpadClient ()

/** This application's OAuth client ID.
 */
@property (strong, nonatomic) NSString *clientId;

/** This application's OAuth client secret key.
 */
@property (strong, nonatomic) NSString *clientSecret;

/** This application's OAuth redirect URI, which is passed in as a post-authentication callback.
 */
@property (strong, nonatomic) NSString *redirectUri;

@end

@implementation BDKLaunchpadClient

@synthesize clientId = _clientId, clientSecret = _clientSecret, redirectUri = _redirectUri;

+ (id)sharedInstance {
    static BDKLaunchpadClient *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[BDKLaunchpadClient alloc] initWithBaseURL:
                            [@"https://launchpad.37signals.com/authorization" urlValue]];
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
    return [NSURL URLWithString:[NSString stringWithFormat:kBDKLaunchpadURL, clientID, redirectURI]];
}

+ (void)setBearerToken:(NSString *)bearerToken {
    [[self sharedInstance] setDefaultHeader:@"Authorization"
                                      value:[NSString stringWithFormat:@"Bearer %@", bearerToken]];
}

+ (void)getAccessTokenForVerificationCode:(NSString *)verificationCode
                                  success:(TokenSuccessBlock)success
                                  failure:(FailureBlock)failure {
    NSDictionary *params = @{@"type": @"web_server",
                             @"client_id": [[self sharedInstance] clientId],
                             @"redirect_uri": [[self sharedInstance] redirectUri],
                             @"client_secret": [[self sharedInstance] clientSecret],
                             @"code": [verificationCode stringByUrlEncoding]};
    [[self sharedInstance] postPath:@"token" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

+ (void)getAuthorization:(AuthDataBlock)success failure:(FailureBlock)failure {
    [[self sharedInstance] getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BDKLPAuthorizationData *authData = [BDKLPAuthorizationData modelWithDictionary:responseObject];
        success(authData);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error, operation.response.statusCode);
    }];
}

@end
