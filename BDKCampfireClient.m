#import "BDKCampfireClient.h"
#import "BDKCFModels.h"

#import <AFNetworking/AFHTTPRequestOperation.h>

@interface BDKCampfireClient ()

- (void)getRoomsForPath:(NSString *)path success:(ArrayBlock)success failure:(FailureBlock)failure;

- (void)getMessagesForPath:(NSString *)path
                    params:(NSDictionary *)params
                   success:(ArrayBlock)success
                   failure:(FailureBlock)failure;

- (void)getUploadsForPath:(NSString *)path
                   params:(NSDictionary *)params
                  success:(ArrayBlock)success
                  failure:(FailureBlock)failure;

- (void)handleFailureForOperation:(AFHTTPRequestOperation *)operation
                            error:(NSError *)error
                         callback:(FailureBlock)callback;

@end

@implementation BDKCampfireClient

- (id)initWithBaseURL:(NSURL *)url accessToken:(NSString *)accessToken
{
    if (self = [super initWithBaseURL:url]) {
        [self setAuthorizationHeaderWithToken:accessToken];
    }
    return self;
}

- (id)initWithSubdomain:(NSString *)subdomain accessToken:(NSString *)accessToken
{
    return [self initWithBaseURL:[NSString stringWithFormat:kBDKCampfireBaseURL, subdomain] accessToken:accessToken];
}

- (void)cancelRequestsWithPrefix:(NSString *)prefix
{
    NSString *requestMatch = [NSString stringWithFormat:@"%@%@", [self baseURL], prefix];
    [self.operationQueue.operations each:^(AFHTTPRequestOperation *operation) {
        if ([operation.request.URL.description hasPrefix:requestMatch]) [operation cancel];
    }];
}

#pragma mark - Private methods

- (void)getRoomsForPath:(NSString *)path success:(ArrayBlock)success failure:(FailureBlock)failure
{
    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rooms = [responseObject[@"rooms"] map:^BDKCFRoom *(NSDictionary *room) {
            return [BDKCFRoom modelWithDictionary:room];
        }];
        success(rooms);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

- (void)getMessagesForPath:(NSString *)path
                    params:(NSDictionary *)params
                   success:(ArrayBlock)success
                   failure:(FailureBlock)failure
{
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *messages = [responseObject[@"messages"] map:^BDKCFMessage *(NSDictionary *message) {
            return [BDKCFMessage modelWithDictionary:message];
        }];
        success(messages);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}


- (void)getUploadsForPath:(NSString *)path
                   params:(NSDictionary *)params
                  success:(ArrayBlock)success
                  failure:(FailureBlock)failure
{
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *uploads = [responseObject[@"uploads"] map:^BDKCFUpload *(NSDictionary *upload) {
            return [BDKCFUpload modelWithDictionary:upload];
        }];
        success(uploads);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

- (void)handleFailureForOperation:(AFHTTPRequestOperation *)operation
                            error:(NSError *)error
                         callback:(FailureBlock)callback
{
    DDLogWarn(@"API failure %i, %@.", operation.response.statusCode, error.localizedDescription);
    callback(error, operation.response.statusCode);
    callback = nil;
}

#pragma mark - Account methods

- (void)getCurrentAccount:(AccountBlock)success failure:(FailureBlock)failure
{
    NSString *path = @"account";
    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BDKCFAccount *account = [BDKCFAccount modelWithDictionary:responseObject[@"account"]];
        success(account);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

#pragma mark - Message methods

- (void)postMessage:(BDKCFMessage *)message
             toRoom:(NSNumber *)roomId
            success:(MessageBlock)success
            failure:(FailureBlock)failure
{
    NSString *path = NSStringWithFormat(@"room/%@/speak", roomId);
    [self postPath:path parameters:message.asApiData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BDKCFMessage *message = [BDKCFMessage modelWithDictionary:responseObject[@"message"]];
        success(message);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

- (void)getMessagesForRoom:(NSNumber *)roomId
            sinceMessageId:(NSNumber *)sinceMessageId
                   success:(ArrayBlock)success
                   failure:(FailureBlock)failure
{
    [self getMessagesForRoom:roomId limit:100 sinceMessageId:sinceMessageId success:success failure:failure];
}

- (void)getMessagesForRoom:(NSNumber *)roomId
                     limit:(NSInteger)limit
            sinceMessageId:(NSNumber *)sinceMessageId
                   success:(ArrayBlock)success
                   failure:(FailureBlock)failure
{
    if (limit > 100) limit = 100;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"limit": @(limit)}];
    if (sinceMessageId) params[@"since_message_id"] = sinceMessageId;
    [self getMessagesForPath:NSStringWithFormat(@"room/%@/recent", roomId) params:params success:success failure:failure];
}

- (void)highlightMessage:(NSNumber *)messageId success:(EmptyBlock)success failure:(FailureBlock)failure
{
    NSString *path = NSStringWithFormat(@"messages/%@/star", messageId);
    [self postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

- (void)unhighlightMessage:(NSNumber *)messageId success:(EmptyBlock)success failure:(FailureBlock)failure
{
    NSString *path = NSStringWithFormat(@"messages/%@/star", messageId);
    [self deletePath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

#pragma mark - Room methods

- (void)getRooms:(ArrayBlock)success failure:(FailureBlock)failure
{
    return [self getRoomsForPath:@"rooms" success:success failure:failure];
}

- (void)getPresentRooms:(ArrayBlock)success failure:(FailureBlock)failure
{
    return [self getRoomsForPath:@"presence" success:success failure:failure];
}

- (void)getRoomForId:(NSNumber *)roomId success:(RoomBlock)success failure:(FailureBlock)failure
{
    NSString *path = NSStringWithFormat(@"room/%@", roomId);
    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BDKCFRoom *room = [BDKCFRoom modelWithDictionary:responseObject[@"room"]];
        success(room);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

- (void)updateRoom:(BDKCFRoom *)room success:(EmptyBlock)success failure:(FailureBlock)failure
{
    NSString *path = NSStringWithFormat(@"room/%@", room.identifier);
    [self putPath:path parameters:room.asApiData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

- (void)joinRoom:(NSNumber *)roomId success:(EmptyBlock)success failure:(FailureBlock)failure
{
    NSString *path = NSStringWithFormat(@"room/%@/join", roomId);
    [self postPath:path parameters:nil
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               success();
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               [self handleFailureForOperation:operation error:error callback:failure];
           }];
}

- (void)leaveRoom:(NSNumber *)roomId success:(EmptyBlock)success failure:(FailureBlock)failure
{
    NSString *path = NSStringWithFormat(@"room/%@/leave", roomId);
    [self postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

- (void)lockRoom:(NSNumber *)roomId success:(EmptyBlock)success failure:(FailureBlock)failure
{
    NSString *path = NSStringWithFormat(@"room/%@/lock", roomId);
    [self postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

- (void)unlockRoom:(NSNumber *)roomId success:(EmptyBlock)success failure:(FailureBlock)failure
{
    NSString *path = NSStringWithFormat(@"room/%@/unlock", roomId);
    [self postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

#pragma mark - Search methods

- (void)searchMessagesForQuery:(NSString *)query success:(ArrayBlock)success failure:(FailureBlock)failure
{
    [self getMessagesForPath:@"search" params:@{@"q": query.stringByUrlEncoding} success:success failure:failure];
}

#pragma mark - Transcript methods

- (void)getTranscriptForTodayForRoomId:(NSNumber *)roomId success:(ArrayBlock)success failure:(FailureBlock)failure
{
    NSString *path = NSStringWithFormat(@"room/%@/transcript", roomId);
    [self getMessagesForPath:path params:nil success:success failure:failure];
}

- (void)getTranscriptForRoomId:(NSNumber *)roomId
                          date:(NSDate *)date
                       success:(ArrayBlock)success
                       failure:(FailureBlock)failure
{
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit)
                                    fromDate:date];
    NSString *path = NSStringWithFormat(@"room/%@/transcript/%@/%@/%@", roomId,
                                        @(components.year), @(components.month), @(components.day));
    [self getMessagesForPath:path params:nil success:success failure:failure];
}

#pragma mark - File upload methods

- (void)uploadFile:(NSData *)file
          filename:(NSString *)filename
            toRoom:(NSNumber *)roomId
           success:(UploadBlock)success
           failure:(FailureBlock)failure
{
    // We're getting the mime type here.
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                            (__bridge CFStringRef)filename,
                                                            NULL);
    NSString *mimeType = (__bridge NSString *)UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension);
    CFRelease(uti);
    void (^appendBlock)(id<AFMultipartFormData>) = ^(id<AFMultipartFormData>formData) {
        [formData appendPartWithFileData:file name:@"upload" fileName:filename mimeType:mimeType];
    };
    void (^progressBlock)(NSUInteger, long long, long long) = ^(NSUInteger written,
                                                                long long totalWritten,
                                                                long long totalToWrite) {
        NSLog(@"Sent %i of %lld bytes", written, totalToWrite);
    };
    void (^completionBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        BDKCFUpload *upload = [BDKCFUpload modelWithDictionary:responseObject[@"upload"]];
        success(upload);
    };
    void (^failureBlock)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    };

    NSString *path = NSStringWithFormat(@"room/%@/uploads", roomId);
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST"
                                                                   path:path
                                                             parameters:nil
                                              constructingBodyWithBlock:appendBlock];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:progressBlock];
    [operation setCompletionBlockWithSuccess:completionBlock failure:failureBlock];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)getRecentUploadsForRoomId:(NSNumber *)roomId success:(ArrayBlock)success failure:(FailureBlock)failure
{
    [self getUploadsForPath:NSStringWithFormat(@"room/%@/uploads", roomId) params:nil success:success failure:failure];
}

- (void)getUploadForMessageId:(NSNumber *)messageId
                       inRoom:(NSNumber *)roomId
                      success:(UploadBlock)success
                      failure:(FailureBlock)failure
{
    NSString *path = NSStringWithFormat(@"room/%@/messages/%@/upload", roomId, messageId);
    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BDKCFUpload *upload = [BDKCFUpload modelWithDictionary:responseObject[@"upload"]];
        success(upload);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

#pragma mark - User methods

- (void)getUserForId:(NSNumber *)userId success:(UserBlock)success failure:(FailureBlock)failure
{
    NSString *path = NSStringWithFormat(@"users/%@", userId);
    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BDKCFUser *user = [BDKCFUser modelWithDictionary:responseObject[@"user"]];
        success(user);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

- (void)getCurrentUser:(UserBlock)success failure:(FailureBlock)failure
{
    NSString *path = @"users/me";
    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BDKCFUser *user = [BDKCFUser modelWithDictionary:responseObject[@"user"]];
        success(user);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

@end


@implementation NSString (BDKCampfireClient)

- (NSString *)stringByUrlEncoding {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'();:@&amp;=+$,/?%#[]", kCFStringEncodingUTF8));
}

@end
