#import "IFBKCampfireClient.h"
#import "IFBKCFModels.h"
#import "NSString+IFBKThirtySeven.h"

#import <AFNetworking/AFNetworking.h>
#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import <MobileCoreServices/MobileCoreServices.h>
#else
#import <CoreServices/CoreServices.h>
#endif

#define kIFBKCampfireBaseURL @"https://%@.campfirenow.com"

@interface IFBKCampfireClient ()

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

@implementation IFBKCampfireClient

- (instancetype)initWithBaseURL:(NSURL *)url accessToken:(NSString *)accessToken {
    self = [super initWithBaseURL:url];
    if (!self) return nil;
    
    [self setBearerToken:accessToken];
    return self;
}

- (instancetype)initWithSubdomain:(NSString *)subdomain accessToken:(NSString *)accessToken {
    NSString *baseURL = [NSString stringWithFormat:kIFBKCampfireBaseURL, subdomain];
    return [self initWithBaseURL:[NSURL URLWithString:baseURL] accessToken:accessToken];
}

- (void)cancelRequestsWithPrefix:(NSString *)prefix {
    NSString *requestMatch = [NSString stringWithFormat:@"%@%@", [self baseURL], prefix];
    for (AFHTTPRequestOperation *operation in [self.operationQueue operations]) {
        if ([[[operation.request URL] description] hasPrefix:requestMatch]) {
            [operation cancel];
        }
    }
}

- (void)setBearerToken:(NSString *)bearerToken {
    [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", bearerToken]
                  forHTTPHeaderField:@"Authorization"];
}

#pragma mark - Private methods

- (void)getRoomsForPath:(NSString *)path success:(ArrayBlock)success failure:(FailureBlock)failure {
    [self GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *rooms = [NSMutableArray arrayWithCapacity:[responseObject[@"rooms"] count]];
        for (NSDictionary *room in responseObject[@"rooms"]) {
            [rooms addObject:[IFBKCFRoom modelWithDictionary:room]];
        }
        success([NSArray arrayWithArray:rooms]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

- (void)getMessagesForPath:(NSString *)path
                    params:(NSDictionary *)params
                   success:(ArrayBlock)success
                   failure:(FailureBlock)failure {
    [self GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *messages = [NSMutableArray arrayWithCapacity:[responseObject[@"messages"] count]];
        for (NSDictionary *message in responseObject[@"messages"]) {
            [messages addObject:[IFBKCFMessage modelWithDictionary:message]];
        }
        success([NSArray arrayWithArray:messages]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}


- (void)getUploadsForPath:(NSString *)path
                   params:(NSDictionary *)params
                  success:(ArrayBlock)success
                  failure:(FailureBlock)failure {
    [self GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *uploads = [NSMutableArray arrayWithCapacity:[responseObject[@"uploads"] count]];
        for (NSDictionary *upload in responseObject[@"uploads"]) {
            [uploads addObject:[IFBKCFUpload modelWithDictionary:upload]];
        }
        success([NSArray arrayWithArray:uploads]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

- (void)handleFailureForOperation:(AFHTTPRequestOperation *)operation
                            error:(NSError *)error
                         callback:(FailureBlock)callback {
    NSLog(@"API failure %li, %@.", (long)operation.response.statusCode, error.localizedDescription);
    callback(error, operation.response);
}

#pragma mark - Account methods

- (void)getCurrentAccount:(AccountBlock)success failure:(FailureBlock)failure {
    NSString *path = @"account";
    [self GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        IFBKCFAccount *account = [IFBKCFAccount modelWithDictionary:responseObject[@"account"]];
        success(account);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

#pragma mark - Message methods

- (void)postMessage:(IFBKCFMessage *)message
             toRoom:(NSNumber *)roomId
            success:(MessageBlock)success
            failure:(FailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"room/%@/speak", roomId];
    [self POST:path parameters:message.asApiData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        IFBKCFMessage *responseMessage = [IFBKCFMessage modelWithDictionary:responseObject[@"message"]];
        success(responseMessage);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

- (void)getMessagesForRoom:(NSNumber *)roomId
            sinceMessageId:(NSNumber *)sinceMessageId
                   success:(ArrayBlock)success
                   failure:(FailureBlock)failure {
    [self getMessagesForRoom:roomId limit:50 sinceMessageId:sinceMessageId success:success failure:failure];
}

- (void)getMessagesForRoom:(NSNumber *)roomId
                     limit:(NSInteger)limit
            sinceMessageId:(NSNumber *)sinceMessageId
                   success:(ArrayBlock)success
                   failure:(FailureBlock)failure {
    if (limit > 100) limit = 100;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"limit": @(limit)}];
    if (sinceMessageId) params[@"since_message_id"] = sinceMessageId;
    NSString *path = [NSString stringWithFormat:@"room/%@/recent", roomId];
    [self getMessagesForPath:path params:params success:success failure:failure];
}

- (void)highlightMessage:(NSNumber *)messageId success:(EmptyBlock)success failure:(FailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"messages/%@/star", messageId];
    [self POST:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

- (void)unhighlightMessage:(NSNumber *)messageId success:(EmptyBlock)success failure:(FailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"messages/%@/star", messageId];
    [self DELETE:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

#pragma mark - Room methods

- (void)getRooms:(ArrayBlock)success failure:(FailureBlock)failure {
    return [self getRoomsForPath:@"rooms" success:success failure:failure];
}

- (void)getPresentRooms:(ArrayBlock)success failure:(FailureBlock)failure {
    return [self getRoomsForPath:@"presence" success:success failure:failure];
}

- (void)getRoomForId:(NSNumber *)roomId success:(RoomBlock)success failure:(FailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"room/%@", roomId];
    [self GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        IFBKCFRoom *room = [IFBKCFRoom modelWithDictionary:responseObject[@"room"]];
        success(room);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

- (void)updateRoom:(IFBKCFRoom *)room success:(EmptyBlock)success failure:(FailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"room/%@", room.identifier];
    [self PUT:path parameters:room.asApiData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

- (void)joinRoom:(NSNumber *)roomId success:(EmptyBlock)success failure:(FailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"room/%@/join", roomId];
    [self POST:path parameters:nil
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               success();
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               [self handleFailureForOperation:operation error:error callback:failure];
           }];
}

- (void)leaveRoom:(NSNumber *)roomId success:(EmptyBlock)success failure:(FailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"room/%@/leave", roomId];
    [self POST:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

- (void)lockRoom:(NSNumber *)roomId success:(EmptyBlock)success failure:(FailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"room/%@/lock", roomId];
    [self POST:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

- (void)unlockRoom:(NSNumber *)roomId success:(EmptyBlock)success failure:(FailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"room/%@/unlock", roomId];
    [self POST:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

#pragma mark - Search methods

- (void)searchMessagesForQuery:(NSString *)query success:(ArrayBlock)success failure:(FailureBlock)failure {
    [self getMessagesForPath:@"search" params:@{@"q": query.stringByUrlEncoding} success:success failure:failure];
}

#pragma mark - Transcript methods

- (void)getTranscriptForTodayForRoomId:(NSNumber *)roomId success:(ArrayBlock)success failure:(FailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"room/%@/transcript", roomId];
    [self getMessagesForPath:path params:nil success:success failure:failure];
}

- (void)getTranscriptForRoomId:(NSNumber *)roomId
                          date:(NSDate *)date
                       success:(ArrayBlock)success
                       failure:(FailureBlock)failure {
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit)
                                    fromDate:date];
    NSString *path = [NSString stringWithFormat:@"room/%@/transcript/%@/%@/%@", roomId,
                                                @(components.year), @(components.month), @(components.day)];
    [self getMessagesForPath:path params:nil success:success failure:failure];
}

#pragma mark - File upload methods

- (void)uploadFile:(NSData *)file
          filename:(NSString *)filename
            toRoom:(NSNumber *)roomId
           success:(UploadBlock)success
          progress:(ProgressBlock)progress
           failure:(FailureBlock)failure {
    // We're getting the mime type here.
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                            (__bridge CFStringRef)filename,
                                                            NULL);
    NSString *mimeType = (__bridge NSString *)UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension);
    CFRelease(uti);
    void (^appendBlock)(id<AFMultipartFormData>) = ^(id<AFMultipartFormData>formData) {
        [formData appendPartWithFileData:file name:@"upload" fileName:filename mimeType:mimeType];
    };

    __block NSProgress *progressInstance = [NSProgress progressWithTotalUnitCount:[file length]];
    void (^progressBlock)(NSUInteger, long long, long long) = ^(NSUInteger written,
                                                                long long totalWritten,
                                                                long long totalToWrite) {
        if (!progressInstance) {
            progressInstance = [NSProgress progressWithTotalUnitCount:totalToWrite];
        }
        [progressInstance setCompletedUnitCount:totalWritten];
        progress(progressInstance);
    };
    void (^completionBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        IFBKCFUpload *upload = [IFBKCFUpload modelWithDictionary:responseObject[@"upload"]];
        success(upload);
    };
    void (^failureBlock)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    };

    NSString *path = [NSString stringWithFormat:@"room/%@/uploads", roomId];
    NSString *urlString = [[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString];
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                URLString:urlString
                                                                               parameters:nil
                                                                constructingBodyWithBlock:appendBlock];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:progressBlock];
    [operation setCompletionBlockWithSuccess:completionBlock failure:failureBlock];
    [operation setResponseSerializer:self.responseSerializer];
    [self.operationQueue addOperation:operation];
}

- (void)getRecentUploadsForRoomId:(NSNumber *)roomId success:(ArrayBlock)success failure:(FailureBlock)failure {
    [self getUploadsForPath:[NSString stringWithFormat:@"room/%@/uploads", roomId]
                     params:nil
                    success:success
                    failure:failure];
}

- (void)getUploadForMessageId:(NSNumber *)messageId
                       inRoom:(NSNumber *)roomId
                      success:(UploadBlock)success
                      failure:(FailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"room/%@/messages/%@/upload", roomId, messageId];
    [self GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        IFBKCFUpload *upload = [IFBKCFUpload modelWithDictionary:responseObject[@"upload"]];
        success(upload);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

#pragma mark - User methods

- (void)getUserForId:(NSNumber *)userId success:(UserBlock)success failure:(FailureBlock)failure {
    NSString *path = [NSString stringWithFormat:@"users/%@", userId];
    [self GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        IFBKCFUser *user = [IFBKCFUser modelWithDictionary:responseObject[@"user"]];
        NSLog(@"API HIT: grabbed user %@.", user.name);
        success(user);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

- (void)getCurrentUser:(UserBlock)success failure:(FailureBlock)failure {
    NSString *path = @"users/me";
    [self GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        IFBKCFUser *user = [IFBKCFUser modelWithDictionary:responseObject[@"user"]];
        success(user);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureForOperation:operation error:error callback:failure];
    }];
}

@end
