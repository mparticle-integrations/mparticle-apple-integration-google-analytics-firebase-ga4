#import "MPKitFirebaseGA4Analytics.h"
#import "Firebase.h"

@implementation MPKitFirebaseGA4Analytics

static NSString *const kMPFIRUserIdValueCustomerID = @"customerId";
static NSString *const kMPFIRUserIdValueEmail = @"email";
static NSString *const kMPFIRUserIdValueMPID = @"mpid";
static NSString *const kMPFIRUserIdValueDeviceStamp = @"deviceApplicationStamp";

static NSString *const reservedPrefixOne = @"firebase_";
static NSString *const reservedPrefixTwo = @"google_";
static NSString *const reservedPrefixThree = @"ga_";
static NSString *const firebaseAllowedCharacters = @"_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
static NSString *const aToZCharacters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

const NSInteger FIR_MAX_CHARACTERS_EVENT_NAME_INDEX = 39;
const NSInteger FIR_MAX_CHARACTERS_IDENTITY_NAME_INDEX = 23;
const NSInteger FIR_MAX_CHARACTERS_EVENT_ATTR_VALUE_INDEX = 99;
const NSInteger FIR_MAX_CHARACTERS_IDENTITY_ATTR_VALUE_INDEX = 35;

#pragma mark Static Methods

+ (NSNumber *)kitCode {
    return @(MPKitInstanceGoogleAnalyticsFirebaseGA4);
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"GA4 for Firebase" className:@"MPKitFirebaseGA4Analytics"];
    [MParticle registerExtension:kitRegister];
}


- (MPKitExecStatus *)execStatus:(MPKitReturnCode)returnCode {
    return [[MPKitExecStatus alloc] initWithSDKCode:self.class.kitCode returnCode:returnCode];
}

#pragma mark MPKitInstanceProtocol methods
- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    _configuration = configuration;
    
    if ([FIRApp defaultApp] == nil) {
        NSAssert(NO, @"There is no instance of Firebase. Check the docs and review your code.");
        return [self execStatus:MPKitReturnCodeFail];
    } else {
        _started = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
    }
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (id const)providerKitInstance {
    return [self started] ? self : nil;
}

- (nonnull MPKitExecStatus *)logBaseEvent:(nonnull MPBaseEvent *)event {
    if ([event isKindOfClass:[MPEvent class]]) {
        return [self routeEvent:(MPEvent *)event];
    } else if ([event isKindOfClass:[MPCommerceEvent class]]) {
        return [self routeCommerceEvent:(MPCommerceEvent *)event];
    } else {
        return [self execStatus:MPKitReturnCodeUnavailable];
    }
}

- (MPKitExecStatus *)routeCommerceEvent:(MPCommerceEvent *)commerceEvent {
    NSDictionary<NSString *, id> *parameters = [self getParameterForCommerceEvent:commerceEvent];
    NSString *eventName = [self getEventNameForCommerceEvent:commerceEvent parameters:parameters];
    if (!eventName) {
        return [self execStatus:MPKitReturnCodeFail];
    }
    
    [FIRAnalytics logEventWithName:eventName parameters:parameters];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)logScreen:(MPEvent *)event {
    if (!event || !event.name) {
        return [self execStatus:MPKitReturnCodeFail];
    }

    NSString *standardizedFirebaseEventName = [self standardizeNameOrKey:event.name forEvent:YES];
    [FIRAnalytics logEventWithName:kFIREventScreenView parameters:@{kFIRParameterScreenName: standardizedFirebaseEventName}];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)routeEvent:(MPEvent *)event {
    if (!event || !event.name) {
        return [self execStatus:MPKitReturnCodeFail];
    }
    
    NSString *standardizedFirebaseEventName = [self standardizeNameOrKey:event.name forEvent:YES];
    event.customAttributes = [self standardizeValues:event.customAttributes forEvent:YES];
    [FIRAnalytics logEventWithName:standardizedFirebaseEventName parameters:event.customAttributes];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (NSString *)standardizeNameOrKey:(NSString *)nameOrKey forEvent:(BOOL)forEvent {
    NSCharacterSet *whitespacesSet = [NSCharacterSet whitespaceCharacterSet];
    NSMutableCharacterSet *firebaseAllowedCharacterSet = [NSMutableCharacterSet characterSetWithCharactersInString:firebaseAllowedCharacters];
    [firebaseAllowedCharacterSet formUnionWithCharacterSet:whitespacesSet];
    NSCharacterSet *notAllowedChars = [firebaseAllowedCharacterSet invertedSet];
    NSString* allowedNameOrKey = [[nameOrKey componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *trimmedString = [regex stringByReplacingMatchesInString:allowedNameOrKey options:0 range:NSMakeRange(0, [allowedNameOrKey length]) withTemplate:@" "];

    NSString *standardizedString = [trimmedString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    if (standardizedString.length > reservedPrefixOne.length && [standardizedString hasPrefix:reservedPrefixOne]) {
        standardizedString = [standardizedString substringFromIndex:reservedPrefixOne.length];
    } else if (standardizedString.length > reservedPrefixTwo.length && [standardizedString hasPrefix:reservedPrefixTwo]) {
        standardizedString = [standardizedString substringFromIndex:reservedPrefixTwo.length];
    } else if (standardizedString.length > reservedPrefixThree.length && [standardizedString hasPrefix:reservedPrefixThree]) {
        standardizedString = [standardizedString substringFromIndex:reservedPrefixThree.length];
    }
    
    NSCharacterSet *letterSet = [NSCharacterSet characterSetWithCharactersInString:aToZCharacters];
    
    while (![letterSet characterIsMember:[standardizedString characterAtIndex:0]] && standardizedString.length > 1) {
        standardizedString = [standardizedString substringFromIndex:1];
    }
    
    if (forEvent) {
        if (standardizedString.length > FIR_MAX_CHARACTERS_EVENT_NAME_INDEX) {
            standardizedString = [standardizedString substringToIndex:FIR_MAX_CHARACTERS_EVENT_NAME_INDEX];
        }
    } else {
        if (standardizedString.length > FIR_MAX_CHARACTERS_IDENTITY_NAME_INDEX) {
            standardizedString = [standardizedString substringToIndex:FIR_MAX_CHARACTERS_IDENTITY_NAME_INDEX];
        }
    }
    
    return standardizedString;
}

- (id)standardizeValue:(id)value forEvent:(BOOL)forEvent {
    id standardizedValue = value;
    if ([value isKindOfClass:[NSString class]]) {
        if (forEvent) {
            if (((NSString *)standardizedValue).length > FIR_MAX_CHARACTERS_EVENT_ATTR_VALUE_INDEX) {
                standardizedValue = [(NSString *)value substringToIndex:FIR_MAX_CHARACTERS_EVENT_ATTR_VALUE_INDEX];
            }
        } else {
            if (((NSString *)standardizedValue).length > FIR_MAX_CHARACTERS_IDENTITY_ATTR_VALUE_INDEX) {
                standardizedValue = [(NSString *)value substringToIndex:FIR_MAX_CHARACTERS_IDENTITY_ATTR_VALUE_INDEX];
            }
        }
    }
    
    return standardizedValue;
}

- (NSDictionary<NSString *, id> *)standardizeValues:(NSDictionary<NSString *, id> *)values forEvent:(BOOL)forEvent {
    NSMutableDictionary<NSString *, id>  *standardizedValue = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in values.allKeys) {
        NSString *standardizedKey = [self standardizeNameOrKey:key forEvent:forEvent];
        standardizedValue[standardizedKey] = [self standardizeValue:values[key] forEvent:forEvent];
    }
    
    return standardizedValue;
}

- (MPKitExecStatus *)onLoginComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    NSString *userId = [self userIdForFirebase:user];
    if (userId) {
        [FIRAnalytics setUserID:userId];
        [self logUserAttributes:user.userAttributes];
        return [self execStatus:MPKitReturnCodeSuccess];
    } else {
        return [self execStatus:MPKitReturnCodeFail];
    }
}

- (MPKitExecStatus *)onIdentifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    NSString *userId = [self userIdForFirebase:user];
    if (userId) {
        [FIRAnalytics setUserID:userId];
        [self logUserAttributes:user.userAttributes];
        return [self execStatus:MPKitReturnCodeSuccess];
    } else {
        return [self execStatus:MPKitReturnCodeFail];
    }
}

- (MPKitExecStatus *)onModifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    NSString *userId = [self userIdForFirebase:user];
    if (userId) {
        [FIRAnalytics setUserID:userId];
        [self logUserAttributes:user.userAttributes];
        return [self execStatus:MPKitReturnCodeSuccess];
    } else {
        return [self execStatus:MPKitReturnCodeFail];
    }
}

- (MPKitExecStatus *)onLogoutComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    NSString *userId = [self userIdForFirebase:user];
    if (userId) {
        [FIRAnalytics setUserID:userId];
        return [self execStatus:MPKitReturnCodeSuccess];
    } else {
        return [self execStatus:MPKitReturnCodeFail];
    }
}

- (MPKitExecStatus *)removeUserAttribute:(NSString *)key {
    [FIRAnalytics setUserPropertyString:nil forName:[self standardizeNameOrKey:key forEvent:NO]];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)setUserAttribute:(NSString *)key value:(id)value {
    [FIRAnalytics setUserPropertyString:[NSString stringWithFormat:@"%@", [self standardizeValue:value forEvent:NO]] forName:[self standardizeNameOrKey:key forEvent:NO]];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
    NSString *userId = [self userIdForFirebase:[self.kitApi getCurrentUserWithKit:self]];
    if (userId) {
        [FIRAnalytics setUserID:userId];
        return [self execStatus:MPKitReturnCodeSuccess];
    } else {
        return [self execStatus:MPKitReturnCodeFail];
    }
}

- (void)logUserAttributes:(NSDictionary<NSString *, id> *)userAttributes {
    NSDictionary<NSString *, id> *standardizedUserAttributes = [self standardizeValues:userAttributes forEvent:NO];
    NSArray *userAttributesKeys = standardizedUserAttributes.allKeys;
    for (NSString *attributeKey in userAttributesKeys) {
        [FIRAnalytics setUserPropertyString:standardizedUserAttributes[attributeKey] forName:attributeKey];
    }
}

- (NSString *)getEventNameForCommerceEvent:(MPCommerceEvent *)commerceEvent parameters:(NSDictionary<NSString *, id> *)parameters {
    switch (commerceEvent.action) {
        case MPCommerceEventActionAddToCart:
            return kFIREventAddToCart;
        case MPCommerceEventActionRemoveFromCart:
            return kFIREventRemoveFromCart;
        case MPCommerceEventActionAddToWishList:
            return kFIREventAddToWishlist;
        case MPCommerceEventActionCheckout:
            return kFIREventBeginCheckout;
        case MPCommerceEventActionCheckoutOptions: {
            NSArray *ga4CommerceEventType = commerceEvent.customFlags[kMPFIRGA4CommerceEventType];
            if (ga4CommerceEventType) {
                if ([ga4CommerceEventType containsObject:kFIREventAddShippingInfo]) {
                    return kFIREventAddShippingInfo;
                } else if ([ga4CommerceEventType containsObject:kFIREventAddPaymentInfo]) {
                    return kFIREventAddPaymentInfo;
                } else {
                    NSLog(@"Warning: Firebase has deprecated CheckoutOption in favor of 'add_shipping_info' and 'add_payment_info'. Review mParticle docs for GA4 Firebase for the custom flags to add.");
                    return kFIREventSetCheckoutOption;
                }
            } else {
                NSLog(@"Warning: Firebase has deprecated CheckoutOption in favor of 'add_shipping_info' and 'add_payment_info'. Review mParticle docs for GA4 Firebase for the custom flags to add.");
                return kFIREventSetCheckoutOption;
            }
        }
        case MPCommerceEventActionClick:
            return kFIREventSelectItem;
        case MPCommerceEventActionViewDetail:
            return kFIREventViewItem;
        case MPCommerceEventActionPurchase:
            return kFIREventPurchase;
        case MPCommerceEventActionRefund:
            return kFIREventRefund;
        default:
            return nil;
    }
}

- (NSDictionary<NSString *, id> *)getParameterForCommerceEvent:(MPCommerceEvent *)commerceEvent {
    NSMutableDictionary<NSString *, id> *parameters = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *itemArray = [[NSMutableArray alloc] init];
    for (MPProduct *product in commerceEvent.products) {
        NSMutableDictionary<NSString *, id> *productParameters = [[NSMutableDictionary alloc] init];
        
        if (product.quantity) {
            [productParameters setObject:product.quantity forKey:kFIRParameterQuantity];
        }
        if (product.sku) {
            [productParameters setObject:product.sku forKey:kFIRParameterItemID];
        }
        if (product.name) {
            [productParameters setObject:product.name forKey:kFIRParameterItemName];
        }
        if (product.category) {
            [productParameters setObject:product.category forKey:kFIRParameterItemCategory];
        }
        if (product.price) {
            [productParameters setObject:product.price forKey:kFIRParameterPrice];
        }
        
        [itemArray addObject:productParameters];
    }
    
    if (itemArray.count > 0) {
        [parameters setObject:itemArray forKey:kFIRParameterItems];
    }
    
    NSString *currency = commerceEvent.currency;
    if (!currency) {
        NSLog(@"Warning: Currency field required by Firebase was not set, defaulting to 'USD'");
        currency = @"USD";
    }
    [parameters setObject:currency forKey:kFIRParameterCurrency];
    
    if (commerceEvent.transactionAttributes.revenue) {
        [parameters setObject:commerceEvent.transactionAttributes.revenue forKey:kFIRParameterValue];
    }
    if (commerceEvent.checkoutStep != NSNotFound) {
        [parameters setObject:@(commerceEvent.checkoutStep) forKey:kFIRParameterCheckoutStep];
    }
    if (commerceEvent.checkoutOptions) {
        [parameters setObject:commerceEvent.checkoutOptions forKey:kFIRParameterCheckoutOption];
    }
    if (commerceEvent.transactionAttributes.transactionId) {
        [parameters setObject:commerceEvent.transactionAttributes.transactionId forKey:kFIRParameterTransactionID];
    }
    if (commerceEvent.transactionAttributes.tax) {
        [parameters setObject:commerceEvent.transactionAttributes.tax forKey:kFIRParameterTax];
    }
    if (commerceEvent.transactionAttributes.shipping) {
        [parameters setObject:commerceEvent.transactionAttributes.shipping forKey:kFIRParameterShipping];
    }
    if (commerceEvent.transactionAttributes.couponCode) {
        [parameters setObject:commerceEvent.transactionAttributes.couponCode forKey:kFIRParameterCoupon];
    }
    
    if (commerceEvent.action == MPCommerceEventActionClick) {
        [parameters setObject:@"product" forKey:kFIRParameterContentType];
    }
    
    NSArray *ga4CommerceEventType = commerceEvent.customFlags[kMPFIRGA4CommerceEventType];
    if (ga4CommerceEventType) {
        if ([ga4CommerceEventType containsObject:kFIREventAddShippingInfo]) {
            NSArray *shippingTier = commerceEvent.customFlags[kMPFIRGA4ShippingTier];
            if (shippingTier.count > 0) {
                [parameters setObject:shippingTier[0] forKey:kFIRParameterShippingTier];
            }
        }
        if ([ga4CommerceEventType containsObject:kFIREventAddPaymentInfo]) {
            NSArray *paymentInfo = commerceEvent.customFlags[kMPFIRGA4PaymentType];
            if (paymentInfo.count > 0) {
                [parameters setObject:paymentInfo[0] forKey:kFIRParameterPaymentType];
            }
        }
    }
    
    return parameters;
}

- (NSString * _Nullable)userIdForFirebase:(FilteredMParticleUser *)currentUser {
    NSString *userId;
    if (currentUser != nil && self.configuration[kMPFIRGA4UserIdFieldKey] != nil) {
        NSString *key = self.configuration[kMPFIRGA4UserIdFieldKey];
        if ([key isEqualToString:kMPFIRUserIdValueCustomerID] && currentUser.userIdentities[@(MPUserIdentityCustomerId)] != nil) {
            userId = currentUser.userIdentities[@(MPUserIdentityCustomerId)];
        } else if ([key isEqualToString:kMPFIRUserIdValueEmail] && currentUser.userIdentities[@(MPUserIdentityEmail)] != nil) {
            userId = currentUser.userIdentities[@(MPUserIdentityEmail)];
        } else if ([key isEqualToString:kMPFIRUserIdValueMPID] && currentUser.userId != nil) {
            userId = currentUser.userId != 0 ? [currentUser.userId stringValue] : nil;
        } else if ([key isEqualToString:kMPFIRUserIdValueDeviceStamp]) {
            userId = [[[MParticle sharedInstance] identity] deviceApplicationStamp];
        }
    }
    return userId;
}

@end
