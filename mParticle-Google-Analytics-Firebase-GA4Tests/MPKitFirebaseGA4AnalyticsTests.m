#import <XCTest/XCTest.h>
#import "MPKitFirebaseGA4Analytics.h"
#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseAnalytics/FIRAnalytics.h>

@interface FIRApp()
+ (void)resetApps;
@end

@interface MPKitFirebaseGA4Analytics()
- (NSString *)standardizeNameOrKey:(NSString *)nameOrKey forEvent:(BOOL)forEvent;
- (NSString *)standardizeValue:(id)value forEvent:(BOOL)forEvent;
- (NSString *)getEventNameForCommerceEvent:(MPCommerceEvent *)commerceEvent parameters:(NSDictionary<NSString *, id> *)parameters;
- (NSDictionary<NSString *, id> *)getParameterForCommerceEvent:(MPCommerceEvent *)commerceEvent;
- (NSMutableDictionary<NSString *, id> *)getParametersForScreen:(MPEvent *)screenEvent;
@end

@interface mParticle_Firebase_AnalyticsTests : XCTestCase
@end

@implementation mParticle_Firebase_AnalyticsTests

- (void)setUp {
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] resourcePath];
    NSString *filePath = [bundlePath stringByAppendingPathComponent:@"GoogleService-Info.plist"];
    FIROptions *options = [[FIROptions alloc] initWithContentsOfFile:filePath];
    [FIRApp configureWithOptions:options];
}

- (void)tearDown {
    [MPKitFirebaseGA4Analytics setCustomNameStandardization:nil];
    [FIRApp resetApps];
}

- (void)testStarted {
    MPKitFirebaseGA4Analytics *exampleKit = [[MPKitFirebaseGA4Analytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{}];
    
    XCTAssertTrue(exampleKit.started);
}

- (void)testLogCommerceEvent {
    MPKitFirebaseGA4Analytics *exampleKit = [[MPKitFirebaseGA4Analytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{}];
    
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionCheckoutOptions];
    MPKitExecStatus *execStatus = [exampleKit logBaseEvent:event];
    XCTAssertTrue(execStatus.success);
}

- (void)testLogCommerceEventPurchase {
    MPKitFirebaseGA4Analytics *exampleKit = [[MPKitFirebaseGA4Analytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{}];
    
    MPProduct *product = [[MPProduct alloc] initWithName:@"Tardis" sku:@"9who" quantity:@1 price:@42.0];
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionPurchase product:product];
    MPKitExecStatus *execStatus = [exampleKit logBaseEvent:event];
    
    XCTAssertTrue(execStatus.success);
}

- (void)testLogCommerceEventImpression {
    MPKitFirebaseGA4Analytics *exampleKit = [[MPKitFirebaseGA4Analytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{}];
    
    MPProduct *product = [[MPProduct alloc] initWithName:@"Tardis" sku:@"9who" quantity:@1 price:@42.0];
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithImpressionName:@"suggested products list" product:product];
    MPKitExecStatus *execStatus = [exampleKit logBaseEvent:event];
    
    XCTAssertTrue(execStatus.success);
}

- (void)testLogCommerceEventPromotion {
    MPKitFirebaseGA4Analytics *exampleKit = [[MPKitFirebaseGA4Analytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{}];
    
    MPPromotion *promotion = [[MPPromotion alloc] init];
    promotion.promotionId = @"my_promo_1";
    promotion.creative = @"sale_banner_1";
    promotion.name = @"App-wide 50% off sale";
    promotion.position = @"dashboard_bottom";
    
    MPPromotionContainer *container = [[MPPromotionContainer alloc] initWithAction:MPPromotionActionView promotion:promotion];
    
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithPromotionContainer:container];
    
    MPKitExecStatus *execStatus = [exampleKit logBaseEvent:event];
    
    XCTAssertTrue(execStatus.success);
}

- (void)testLogEvent {
    MPKitFirebaseGA4Analytics *exampleKit = [[MPKitFirebaseGA4Analytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{}];
    
    MPEvent *event = [[MPEvent alloc] initWithName:@"example" type:MPEventTypeOther];
    MPKitExecStatus *execStatus = [exampleKit logBaseEvent:event];
    
    XCTAssertTrue(execStatus.success);
}

- (void)testLogEventWithNilEvent {
    MPKitFirebaseGA4Analytics *exampleKit = [[MPKitFirebaseGA4Analytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{}];
    
    MPEvent *event = nil;
    MPKitExecStatus *execStatus = [exampleKit logBaseEvent:event];
    
    XCTAssertFalse(execStatus.success);
}

- (void)testSanitization {
    MPKitFirebaseGA4Analytics *exampleKit = [[MPKitFirebaseGA4Analytics alloc] init];
    
    NSArray *badPrefixes = @[@"firebase_event_name",
                             @"google_event_name",
                             @"ga_event_name"];
    for (NSString *badPrefix in badPrefixes) {
        XCTAssertEqualObjects([exampleKit standardizeNameOrKey:badPrefix forEvent:YES], @"event_name");
    }
    
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event name" forEvent:YES], @"event_name");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event_name " forEvent:YES], @"event_name_");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event  name " forEvent:YES], @"event__name_");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event - name " forEvent:YES], @"event___name_");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event! - ?name " forEvent:YES], @"event_____name_");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event name" forEvent:NO], @"event name");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event_name " forEvent:NO], @"event_name ");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event  name " forEvent:NO], @"event  name ");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event - name " forEvent:NO], @"event - name ");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event! - ?name " forEvent:NO], @"event! - ?name ");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event! - ?name " forEvent:NO], @"event! - ?name ");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"!@#$%^&*()_+=[]{}|'\"?>" forEvent:NO], @"!@#$%^&*()_+=[]{}|'\"?>");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"   event_name" forEvent:NO], @"   event_name");
    
    
    
    NSArray *badStarts = @[@"!@#$%^&*()_+=[]{}|'\"?><:;event_name",
                           @"_event_name",
                           @"   event_name",
                           @"_event_name"];
    
    for (NSString *badStart in badStarts) {
        XCTAssertEqualObjects([exampleKit standardizeNameOrKey:badStart forEvent:YES], @"event_name");
    }
    
    NSString *tooLong = @"abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890";
    XCTAssertEqual(40, [exampleKit standardizeNameOrKey:tooLong forEvent:YES].length);
    XCTAssertEqual(24, [exampleKit standardizeNameOrKey:tooLong forEvent:NO].length);
    XCTAssertEqual(500, [exampleKit standardizeValue:tooLong forEvent:YES].length);
    XCTAssertEqual(36, [exampleKit standardizeValue:tooLong forEvent:NO].length);
    
    NSArray *emptyStrings = @[@"!@#$%^&*()_+=[]{}|'\"?><:;",
                              @"_1234567890",
                              @" ",
                              @""];
    for (NSString *emptyString in emptyStrings) {
        XCTAssertEqualObjects([exampleKit standardizeNameOrKey:emptyString forEvent:YES], @"invalid_ga4_key");
    }
}

- (void)testSanitizationCustom {
    MPKitFirebaseGA4Analytics *exampleKit = [[MPKitFirebaseGA4Analytics alloc] init];
    
    NSArray *customTest = @[@"firebase_event_name",
                             @"google_event_name",
                             @"ga_event_name"];
    
    [MPKitFirebaseGA4Analytics setCustomNameStandardization:^(NSString* name) {
        return @"test";
    }];
    for (NSString *tests in customTest) {
        XCTAssertEqualObjects([exampleKit standardizeNameOrKey:tests forEvent:YES], @"test");
    }
    
    for (NSString *tests in customTest) {
        XCTAssertEqualObjects([exampleKit standardizeNameOrKey:tests forEvent:NO], @"test");
    }
}

- (void)testSanitizationMax {
    MPKitFirebaseGA4Analytics *exampleKit = [[MPKitFirebaseGA4Analytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{}];
    
    NSDictionary *testAttributes = @{ @"test1": @"parameter",
                                      @"test2": @"parameter",
                                      @"test3": @"parameter",
                                      @"test4": @"parameter",
                                      @"test5": @"parameter",
                                      @"test6": @"parameter",
                                      @"test7": @"parameter",
                                      @"test8": @"parameter",
                                      @"test9": @"parameter",
                                      @"test10": @"parameter",
                                      @"test11": @"parameter",
                                      @"test12": @"parameter",
                                      @"test13": @"parameter",
                                      @"test14": @"parameter",
                                      @"test15": @"parameter",
                                      @"test16": @"parameter",
                                      @"test17": @"parameter",
                                      @"test18": @"parameter",
                                      @"test19": @"parameter",
                                      @"test20": @"parameter",
                                      @"test21": @"parameter",
                                      @"test22": @"parameter",
                                      @"test23": @"parameter",
                                      @"test24": @"parameter"
          };
    NSDictionary *testFinalAttributes = @{ @"test1": @"parameter",
                                           @"test2": @"parameter",
                                           @"test3": @"parameter",
                                           @"test4": @"parameter",
                                           @"test5": @"parameter",
                                           @"test6": @"parameter",
                                           @"test7": @"parameter",
                                           @"test8": @"parameter",
                                           @"test9": @"parameter",
                                           @"test10": @"parameter",
                                           @"test11": @"parameter",
                                           @"test12": @"parameter",
                                           @"test13": @"parameter",
                                           @"test14": @"parameter",
                                           @"test15": @"parameter",
                                           @"test16": @"parameter",
                                           @"test17": @"parameter",
                                           @"test18": @"parameter",
                                           @"test19": @"parameter",
                                           @"test20": @"parameter",
                                           @"test21": @"parameter",
                                           @"test22": @"parameter",
                                           @"test23": @"parameter",
                                           @"test24": @"parameter",
                                           @"currency": @"USD"
          };
    
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionCheckoutOptions];
    event.customAttributes = testAttributes;
    
    NSDictionary<NSString *, id> *parameters = [exampleKit getParameterForCommerceEvent:event];
    XCTAssertEqual([parameters count], 25);
    XCTAssertEqualObjects(parameters, testFinalAttributes);
    
    NSMutableDictionary *testExcessiveAttributes = [[NSMutableDictionary alloc] initWithCapacity:125];
    for (int i = 0; i < 125; i++) {
        NSString *key = [NSString stringWithFormat:@"test%03d", i];
        testExcessiveAttributes[key] = @"parameter";
    }
    
    NSMutableDictionary *testExcessiveFinalAttributes = [[NSMutableDictionary alloc] initWithCapacity:125];
    for (int i = 0; i <99 ; i++) {
        NSString *key = [NSString stringWithFormat:@"test%03d", i];
        testExcessiveFinalAttributes[key] = @"parameter";
    }
    testExcessiveFinalAttributes[@"currency"] = @"USD";
    
    event.customAttributes = testExcessiveAttributes;
    
    parameters = [exampleKit getParameterForCommerceEvent:event];
    XCTAssertEqual([parameters count], 100);
    XCTAssertEqualObjects(parameters, testExcessiveFinalAttributes);


    MPKitExecStatus *execStatus = [exampleKit logBaseEvent:event];
    XCTAssertTrue(execStatus.success);
    
    MPProduct *product1 = [[MPProduct alloc] initWithName:@"William Hartnell" sku:@"1who" quantity:@1 price:@42.0];
    MPProduct *product2 = [[MPProduct alloc] initWithName:@"Patrick Troughton" sku:@"2who" quantity:@1 price:@42.0];
    MPProduct *product3 = [[MPProduct alloc] initWithName:@"Jon Pertwee" sku:@"3who" quantity:@1 price:@42.0];
    MPProduct *product4 = [[MPProduct alloc] initWithName:@"Tom Baker" sku:@"4who" quantity:@1 price:@42.0];
    MPProduct *product5 = [[MPProduct alloc] initWithName:@"Peter Davison" sku:@"5who" quantity:@1 price:@42.0];
    MPProduct *product6 = [[MPProduct alloc] initWithName:@"Colin Baker" sku:@"6who" quantity:@1 price:@42.0];
    MPProduct *product7 = [[MPProduct alloc] initWithName:@"Sylvester McCoy" sku:@"7who" quantity:@1 price:@42.0];
    MPProduct *product8 = [[MPProduct alloc] initWithName:@"Paul McGann" sku:@"8who" quantity:@1 price:@42.0];
    MPProduct *product9 = [[MPProduct alloc] initWithName:@"Christopher Eccleston" sku:@"9who" quantity:@1 price:@42.0];
    MPProduct *product10 = [[MPProduct alloc] initWithName:@"David Tennant" sku:@"10who" quantity:@1 price:@42.0];
    MPProduct *product11 = [[MPProduct alloc] initWithName:@"Matt Smith" sku:@"11who" quantity:@1 price:@42.0];
    MPProduct *product12 = [[MPProduct alloc] initWithName:@"Peter Capaldi" sku:@"12who" quantity:@1 price:@42.0];
    MPProduct *product13 = [[MPProduct alloc] initWithName:@"Jodie Whittaker" sku:@"13who" quantity:@1 price:@42.0];

    MPCommerceEvent *purchaseEvent = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionPurchase];
    purchaseEvent.products = @[product1, product2, product3, product4, product5, product6, product7, product8, product9, product10, product11, product12, product13];
    
    parameters = [exampleKit getParameterForCommerceEvent:purchaseEvent];
    XCTAssertEqual([parameters count], 2);
    XCTAssertEqual([parameters[@"items"] count], 13);
    XCTAssertTrue([parameters[@"items"][0] count] <= 10);

    execStatus = [exampleKit logBaseEvent:purchaseEvent];
    XCTAssertTrue(execStatus.success);
}

- (void)testCommerceEventCheckoutOptions {
    MPKitFirebaseGA4Analytics *exampleKit = [[MPKitFirebaseGA4Analytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{}];
    
    // Test kFIREventAddShippingInfo
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionCheckoutOptions];
    [event addCustomFlag:kFIREventAddShippingInfo withKey:kMPFIRGA4CommerceEventType];
    NSDictionary<NSString *, id> *parameters = [exampleKit getParameterForCommerceEvent:event];
    NSString *eventName = [exampleKit getEventNameForCommerceEvent:event parameters:parameters];
    XCTAssertEqualObjects(kFIREventAddShippingInfo, eventName);

    // Test kFIREventAddPaymentInfo
    event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionCheckoutOptions];
    [event addCustomFlag:kFIREventAddPaymentInfo withKey:kMPFIRGA4CommerceEventType];
    eventName = [exampleKit getEventNameForCommerceEvent:event parameters:parameters];
    XCTAssertEqualObjects(kFIREventAddPaymentInfo, eventName);

    // Test both (defaults to kFIREventAddShippingInfo)
    event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionCheckoutOptions];
    [event addCustomFlags:@[kFIREventAddShippingInfo, kFIREventAddPaymentInfo] withKey:kMPFIRGA4CommerceEventType];
    eventName = [exampleKit getEventNameForCommerceEvent:event parameters:parameters];
    XCTAssertEqualObjects(kFIREventAddShippingInfo, eventName);
}

- (void)testScreenNameAttributes {
    MPKitFirebaseGA4Analytics *exampleKit = [[MPKitFirebaseGA4Analytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{}];
    
    MPEvent *event = [[MPEvent alloc] initWithName:@"testScreenName" type:MPEventTypeOther];
    event.customAttributes = @{@"testScreenAttribute":@"value"};
    MPKitExecStatus *execStatus = [exampleKit logScreen:event];
    
    XCTAssertTrue(execStatus.success);
    
    NSMutableDictionary<NSString *, id> *screenParameters = [exampleKit getParametersForScreen:event];
    
    // Even though we only pass one custom attribute, the parameters should include the standardized screen name, so the total expected count is two
    XCTAssertEqual(screenParameters.count, 2);
    
    NSString *standardizedScreenName = [exampleKit standardizeNameOrKey:event.name forEvent:YES];
    NSString *screenNameParameter = screenParameters[kFIRParameterScreenName];

    // Test screen name parameter is not Nil and exists in the screen parameters dictionary
    XCTAssertNotNil(screenNameParameter);
    // Test screen name parameter value is correct
    XCTAssertEqualObjects(screenNameParameter, standardizedScreenName);
}

@end
