#import "IFBKThirtySevenClient.h"

@class IFBKLPAuthorizationData;

typedef void (^TokenSuccessBlock)(NSString *accessToken, NSString *refreshToken, NSDate *expiresAt);
typedef void (^TokenRefreshSuccessBlock)(NSString *accessToken, NSDate *expiresAt);
typedef void (^AuthDataBlock)(IFBKLPAuthorizationData *authData);

/**
 An adapter for accessing the 37signals Launchpad API, used with user authentication and OAuth2.
 */
@interface IFBKLaunchpadClient : IFBKThirtySevenClient

/**
 Grabs a singleton instance of the adapter so manual requests can be made.

 @return the singleton instance.
 */
+ (instancetype)sharedInstance;

/**
 Stores OAuth token identifier information in the shared singleton instance.

 @param clientId The OAuth client ID.
 @param clientSecret The OAuth client secret key.
 @param redirectUri The OAuth redirect URI, which is passed in as a post-authentication callback
 */
+ (void)setClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret redirectUri:(NSString *)redirectUri;

/**
 Builds the URL for a Launchpad authentication flow, to be used with a UIWebView in retrieving a verification code.

 @return A URL with the application's client key and redirect URI as parameters.
 */
+ (NSURL *)launchpadURL;

/**
 Stores the OAuth token inside the adapter for all future calls.

 @param bearerToken The string of the OAuth token; will be set with "Bearer %@".
 */
+ (void)setBearerToken:(NSString *)bearerToken;

/**
 Calls the Launchpad API to retrieve an OAuth access token, a refresh token, and the duration of the token's life.
 Upon successful verification, the access token returned by the success block is also set in the adapter's
 authentication header for future API calls.

 @param verificationCode The short code returned by the OAuth2 login action; cannot be nil.
 @param success A block to be called upon successful verification of the verificationCode. Will be handed the
                accessToken, refreshToken, and expiresAt objects.
 @param failure A block to be called upon potential failure. Will be handed an error and HTTP status code.
 */
+ (void)getAccessTokenForVerificationCode:(NSString *)verificationCode
                                  success:(TokenSuccessBlock)success
                                  failure:(FailureBlock)failure;

/**
 Calls the Launchpad API to refresh an OAuth access token based on a refresh token previously granted to the client.
 Upon successful verification, the access token returned by the success block is also set in the adapter's
 authentication header for future API calls.

 @param refreshToken The refresh token returned by a call to get previous access token; cannot be nil.
 @param success A block to be called upon successful refresh of the token. Will be handed a new accessToken
                and expiresAt objects.
 @param failure A block to be called upon potential failure. Will be handed an error and HTTP status code.
 */
+ (void)refreshAccessTokenWithRefreshToken:(NSString *)refreshToken
                                   success:(TokenRefreshSuccessBlock)success
                                   failure:(FailureBlock)failure;

/**
 Calls the Launchpad API to ensure the current access token is still good, and retrieves a list of services to which
 the currently-authenticated user has access.

 @param success A block to be called upon successful verification of the verificationCode. Will be handed the
                accessToken, refreshToken, and expiresAt objects.
 @param failure A block to be called upon potential failure. Will be handed an error and HTTP status code.
 */
+ (void)getAuthorizationData:(AuthDataBlock)success failure:(FailureBlock)failure;

@end
