#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <IFBKThirtySeven/IFBKThirtySeven.h>
#import <SBJson/SBJson.h>

SPEC_BEGIN(IFBKCampfireClientSpec)

describe(@"IFBKCampfireClient", ^{

    __block IFBKCampfireClient *sut;

    beforeAll(^{
        [[LSNocilla sharedInstance] start];
    });

    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });

    beforeEach(^{
        sut = [[IFBKCampfireClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://example.campfirenow.com"] accessToken:@"abcdefg"];
    });

    afterEach(^{
        [[LSNocilla sharedInstance] clearStubs];
    });

    context(@"In case of a sucessful response", ^{

        __block NSString *response;

        beforeEach(^{
            NSDictionary *responseDictionary = @{
                                                 @"account": @{
                                                         @"created_at": @"2012/01/01 12:18:17 +0000",
                                                         @"id": @123456,
                                                         @"name": @"Example",
                                                         @"owner_id": @1234567,
                                                         @"plan": @"basic",
                                                         @"storage": @135840626,
                                                         @"subdomain": @"Example",
                                                         @"time_zone": @"Europe/Milan",
                                                         @"updated_at": @"2013/01/01 12:26:36 +0000"
                                                         }
                                                 };
            response = [[SBJsonWriter new] stringWithObject:responseDictionary];
            stubRequest(@"GET", @"http://example.campfirenow.com/account").
            andReturn(200).
            withHeaders(@{@"Content-Type": @"application/json"}).
            withBody(response);
        });

        it(@"gets the current account", ^{
            __block IFBKCFAccount *capturedAccount;
            [sut getCurrentAccount:^(IFBKCFAccount *account) {
                capturedAccount = account;
            } failure:nil];

            [[expectFutureValue(capturedAccount.name) shouldEventually] equal:@"Example"];
        });
    });
});

SPEC_END
