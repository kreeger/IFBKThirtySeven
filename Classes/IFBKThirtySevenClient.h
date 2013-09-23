#import <SystemConfiguration/SystemConfiguration.h>
#import <AFNetworking/AFNetworking.h>

#define kNotificationAPIReachabilityChanged @"NotificationAPIReachabilityChanged"

typedef void (^FailureBlock)(NSError *error, NSInteger responseCode);
typedef void (^SuccessBlock)(id responseObject);
typedef void (^ArrayBlock)(NSArray *result);
typedef void (^EmptyBlock)(void);

/** A generic interface for API clients.
 */
@interface IFBKThirtySevenClient : AFHTTPClient

/**
 The callback dispatch queue on success. If `NULL` (default), the main queue is used.
 */
@property (nonatomic, assign) dispatch_queue_t successCallbackQueue;

/**
 The callback dispatch queue on failure. If `NULL` (default), the main queue is used.
 */
@property (nonatomic, assign) dispatch_queue_t failureCallbackQueue;

/** Cancels any requests in the global queue beginning with a particular prefix.
 *  @param prefix the prefix.
 */
+ (void)cancelRequestsWithPrefix:(NSString *)prefix;

/** The base URL to connect to; this must be overridden in a child class.
 *  @return a string of the base URL with a trailing slash.
 */
+ (NSString *)baseURL;

@end
