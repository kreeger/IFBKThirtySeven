#import "IFBKCampfireStreamingClient.h"

#import "IFBKCFMessage.h"

#import <SBJson/SBJson.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>

#define kIFBKCampfireStreamingBaseURL @"https://streaming.campfirenow.com/"

@interface IFBKCampfireStreamingClient () <SBJsonStreamParserAdapterDelegate>

@property (strong, nonatomic) SBJsonStreamParserAdapter *adapter;
@property (strong, nonatomic) SBJsonStreamParser *parser;
@property (strong, nonatomic) NSURLConnection *connection;
@property (copy, nonatomic) StreamOpenBlock successBlock;
@property (copy, nonatomic) StreamDidReceiveMessageBlock messageReceivedBlock;
@property (copy, nonatomic) StreamDidEncounterErrorBlock failureBlock;
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

    _adapter = [[SBJsonStreamParserAdapter alloc] init];
	_adapter.delegate = self;
	_parser = [[SBJsonStreamParser alloc] init];
	_parser.delegate = self.adapter;
	_parser.supportMultipleDocuments = YES;

    return self;
}

#pragma mark - Public methods

- (void)openConnection:(StreamOpenBlock)success messageReceived:(StreamDidReceiveMessageBlock)messageReceived failure:(StreamDidEncounterErrorBlock)failure {
    self.successBlock = success;
    self.messageReceivedBlock = messageReceived;
    self.failureBlock = failure;
    self.connectionResponseCode = 0;
	self.connection = [[NSURLConnection alloc] initWithRequest:[self request] delegate:self];
}

- (void)reopenConnection {
    self.connectionResponseCode = 0;
	self.connection = [[NSURLConnection alloc] initWithRequest:[self request] delegate:self];
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
    NSString *urlString = [[NSURL URLWithString:path relativeToURL:url] absoluteString];
    NSURLRequest *request = [apiClient.requestSerializer requestWithMethod:@"GET" URLString:urlString parameters:nil];

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
        if (self.successBlock) {
            self.successBlock(httpResponse);
        }
    }
}

// TODO: Improve error handling.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (self.connectionResponseCode == 200) {
        SBJsonStreamParserStatus status = [self.parser parse:data];

        if (status == SBJsonStreamParserError) {
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: self.parser.error };
            NSError *error = [NSError errorWithDomain:@"ERRORDOMAIN" code:0001 userInfo:userInfo];
            if (self.failureBlock) {
                self.failureBlock(error);
            }
        }
    } else {
        // TODO: Differentiate between authentication errors and other errors
        NSString *responseString = [NSString stringWithUTF8String:[data bytes]];
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Unexpected Response code: %lu - %@", (unsigned long)self.connectionResponseCode, responseString] };
        NSError *error = [NSError errorWithDomain:@"ERRORDOMAIN" code:0001 userInfo:userInfo];
        if (self.failureBlock) {
            self.failureBlock(error);
        }

    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (self.failureBlock) {
        self.failureBlock(error);
    }
}

@end
