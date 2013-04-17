#import <AFNetworking/AFHTTPClient.h>

#define kNotificationAPIReachabilityChanged @"NotificationAPIReachabilityChanged"

typedef void (^FailureBlock)(NSError *error, NSInteger responseCode);
typedef void (^SuccessBlock)(id responseObject);
typedef void (^ArrayBlock)(NSArray *result);
typedef void (^EmptyBlock)(void);

/** A generic interface for API clients.
 */
@interface BDKAPIClient : AFHTTPClient

/** Cancels any requests in the global queue beginning with a particular prefix.
 *  @param prefix the prefix.
 */
+ (void)cancelRequestsWithPrefix:(NSString *)prefix;

/** The base URL to connect to; this must be overridden in a child class.
 *  @return a string of the base URL with a trailing slash.
 */
+ (NSString *)baseURL;

@end
