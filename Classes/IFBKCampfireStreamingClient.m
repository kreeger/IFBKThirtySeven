#import "IFBKCampfireStreamingClient.h"

#import "IFBKCFMessage.h"

#import <SBJson/SBJson.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>

#define kIFBKCampfireStreamingBaseURL @"https://streaming.campfirenow.com/"

@interface IFBKCampfireStreamingClient () <SBJsonStreamParserAdapterDelegate>

@property (strong, nonatomic) SBJsonStreamParserAdapter *adapter;
@property (strong, nonatomic) SBJsonStreamParser *parser;
@property (strong, nonatomic) NSURLConnection *connection;
@property (copy, nonatomic) void (^connectionSuccess)(void);
@property (copy, nonatomic) void (^connectionFailure)(NSError *error);
@property (assign) NSUInteger connectionResponseCode;

- (NSURLRequest *)request;

@end

@implementation IFBKCampfireStreamingClient

@synthesize roomId = _roomId, authorizationToken = _authorizationToken;

- (instancetype)initWithRoomId:(NSNumber *)roomId authorizationToken:(NSString *)authorizationToken {
    self = [super init];
    if (!self) return nil;

    _roomId = roomId;
    _authorizationToken = authorizationToken;
    return self;
}

#pragma mark - Public methods

- (void)openConnectionWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    self.connectionSuccess = success;
    self.connectionFailure = failure;
	self.adapter = [[SBJsonStreamParserAdapter alloc] init];
	self.adapter.delegate = self;
	self.parser = [[SBJsonStreamParser alloc] init];
	self.parser.delegate = self.adapter;
	self.parser.supportMultipleDocuments = YES;
    self.connectionResponseCode = 0;
	self.connection = [[NSURLConnection alloc] initWithRequest:[self request] delegate:self];
}

- (void)openConnection {
    [self openConnectionWithSuccess:nil failure:nil];
}

- (void)closeConnection {
    [self.connection cancel];
}

#pragma mark - Private helpers

- (NSURLRequest*)request {
    NSURL *url = [NSURL URLWithString:kIFBKCampfireStreamingBaseURL];
    NSString *path = [NSString stringWithFormat:@"room/%@/live.json", self.roomId];

    AFHTTPRequestOperationManager *apiClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    [apiClient.requestSerializer clearAuthorizationHeader];
    [apiClient.requestSerializer setAuthorizationHeaderFieldWithUsername:self.authorizationToken password:@"X"];
    NSURLRequest *request = [apiClient.requestSerializer requestWithMethod:@"GET" URLString:path parameters:nil];

    return request;
}

#pragma mark - SBJsonStreamParserAdapterDelegate

- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array {
    [NSException raise:NSInternalInconsistencyException format:@"Unexpected Array"];
}

- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict {
    IFBKCFMessage *message = [IFBKCFMessage modelWithDictionary:dict];
    if (self.messageReceivedBlock) self.messageReceivedBlock(message);
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    self.connectionResponseCode = [httpResponse statusCode];
    if (self.connectionResponseCode == 200) {
        if (self.connectionSuccess) {
            self.connectionSuccess();
            self.connectionSuccess = nil;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

    if (self.connectionResponseCode == 200) {
        SBJsonStreamParserStatus status = [self.parser parse:data];

        if (status == SBJsonStreamParserError) {
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: self.parser.error };
            NSError *error = [NSError errorWithDomain:@"ERRORDOMAIN" code:0001 userInfo:userInfo];
            if (self.connectionFailure) {
                self.connectionFailure(error);
            }
        }
    } else {
        NSString *responseString = [NSString stringWithUTF8String:[data bytes]];
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Unexpected Response code: %lu - %@", (unsigned long)self.connectionResponseCode, responseString] };
        NSError *error = [NSError errorWithDomain:@"ERRORDOMAIN" code:0001 userInfo:userInfo];
        if (self.connectionFailure) {
            self.connectionFailure(error);
        }

    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self openConnection];
    if (self.connectionFailure) {
        self.connectionFailure(error);
    }
}

@end
