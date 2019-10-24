#import "MPKitFirebaseAnalytics.h"
#import "Firebase.h"
#import "MPEnums.h"

@interface MPKitFirebaseAnalytics()

@property (nonatomic, strong, readwrite) FIROptions *firebaseOptions;

@end

@implementation MPKitFirebaseAnalytics

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
    return @(MPKitInstanceGoogleAnalyticsFirebase);
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Google Analytics for Firebase" className:@"MPKitFirebaseAnalytics"];
    [MParticle registerExtension:kitRegister];
}


- (MPKitExecStatus *)execStatus:(MPKitReturnCode)returnCode {
    return [[MPKitExecStatus alloc] initWithSDKCode:self.class.kitCode returnCode:returnCode];
}

#pragma mark MPKitInstanceProtocol methods
- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    _configuration = configuration;
    
    if ([FIRApp defaultApp] == nil) {
        static dispatch_once_t FirebasePredicate;
        
        dispatch_once(&FirebasePredicate, ^{
            NSString *googleAppId = configuration[kMPFIRGoogleAppIDKey];
            NSString *gcmSenderId = configuration[kMPFIRSenderIDKey];
            
            if (googleAppId && ![googleAppId isEqualToString:@""] && gcmSenderId && ![gcmSenderId isEqualToString:@""]) {
                FIROptions *options = [[FIROptions alloc] initWithGoogleAppID:googleAppId GCMSenderID:gcmSenderId];
                
                self.firebaseOptions = options;
                [FIRApp configureWithOptions:options];
                
                self->_started = YES;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                        object:nil
                                                                      userInfo:userInfo];
                });
            } else {
                NSLog(@"Invalid Firebase App ID: %@ or invalid Google Project Number: %@", googleAppId, gcmSenderId);
            }
        });
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
    NSDictionary<NSString *, id> *parameters = [[NSMutableDictionary alloc] init];
    
    switch (commerceEvent.action) {
        case MPCommerceEventActionAddToCart: {
            for (MPProduct *product in commerceEvent.products) {
                parameters = [self getParameterForCommerceEvent:commerceEvent andProduct:product withValue:nil];
                
                [FIRAnalytics logEventWithName:kFIREventAddToCart
                                    parameters:parameters];
            }
        }
            break;
            
        case MPCommerceEventActionRemoveFromCart: {
            for (MPProduct *product in commerceEvent.products) {
                parameters = [self getParameterForCommerceEvent:commerceEvent andProduct:product withValue:nil];
                
                [FIRAnalytics logEventWithName:kFIREventRemoveFromCart
                                    parameters:parameters];
            }
        }
            break;
            
        case MPCommerceEventActionAddToWishList: {
            for (MPProduct *product in commerceEvent.products) {
                parameters = [self getParameterForCommerceEvent:commerceEvent andProduct:product withValue:nil];
                
                [FIRAnalytics logEventWithName:kFIREventAddToWishlist
                                    parameters:parameters];
            }
        }
            break;
            
        case MPCommerceEventActionCheckout: {
            NSNumber *value = commerceEvent.transactionAttributes.revenue;
            
            parameters = [self getParameterForCommerceEvent:commerceEvent andProduct:nil withValue:value];
            
            [FIRAnalytics logEventWithName:kFIREventBeginCheckout
                                parameters:parameters];
        }
            break;
            
        case MPCommerceEventActionCheckoutOptions: {
            parameters = [self getParameterForCommerceEvent:commerceEvent andProduct:nil withValue:nil];
            
            [FIRAnalytics logEventWithName:kFIREventSetCheckoutOption
                                parameters:parameters];
        }
            break;
            
        case MPCommerceEventActionClick: {
            for (MPProduct *product in commerceEvent.products) {
                if (product.sku) {
                    [FIRAnalytics logEventWithName:kFIREventSelectContent
                                        parameters:@{
                                                     kFIRParameterContentType: @"product",
                                                     kFIRParameterItemID: product.sku
                                                     }];
                }
            }
        }
            break;
            
        case MPCommerceEventActionViewDetail: {
            if (commerceEvent.products.count > 1) {
                parameters = [self getParameterForCommerceEvent:commerceEvent andProduct:commerceEvent.products[0] withValue:nil];
                
                [FIRAnalytics logEventWithName:kFIREventViewItemList
                                    parameters:parameters];
            }
            
            for (MPProduct *product in commerceEvent.products) {
                parameters = [self getParameterForCommerceEvent:commerceEvent andProduct:product withValue:nil];
                
                [FIRAnalytics logEventWithName:kFIREventViewItem
                                    parameters:parameters];
            }
        }
            break;
            
        case MPCommerceEventActionPurchase: {
            NSNumber *value = commerceEvent.transactionAttributes.revenue;
            
            parameters = [self getParameterForCommerceEvent:commerceEvent andProduct:nil withValue:value];
            
            [FIRAnalytics logEventWithName:kFIREventEcommercePurchase
                                parameters:parameters];
        }
            break;
            
        case MPCommerceEventActionRefund: {
            NSNumber *value = commerceEvent.transactionAttributes.revenue;
            
            [FIRAnalytics logEventWithName:kFIREventPurchaseRefund
                                parameters:@{
                                             kFIRParameterCurrency: commerceEvent.currency,
                                             kFIRParameterValue: value,
                                             kFIRParameterTransactionID: commerceEvent.transactionAttributes.transactionId
                                             }];
        }
            break;
            
        default:
            return [self execStatus:MPKitReturnCodeFail];
            break;
    }
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)logScreen:(MPEvent *)event {
    if (!event || !event.name) {
        return [self execStatus:MPKitReturnCodeFail];
    }

    event.name = [self standardizeNameOrKey:event.name forEvent:YES];
    [FIRAnalytics setScreenName:event.name screenClass:nil];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)routeEvent:(MPEvent *)event {
    if (!event || !event.name) {
        return [self execStatus:MPKitReturnCodeFail];
    }
    
    event.name = [self standardizeNameOrKey:event.name forEvent:YES];
    event.customAttributes = [self standardizeValues:event.customAttributes forEvent:YES];
    [FIRAnalytics logEventWithName:event.name
                        parameters:event.customAttributes];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (NSString *)standardizeNameOrKey:(NSString *)nameOrKey forEvent:(BOOL)forEvent {
    NSString *standardizedString =  [nameOrKey stringByReplacingOccurrencesOfString:@"  " withString:@"_"];
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:firebaseAllowedCharacters] invertedSet];
    standardizedString = [[standardizedString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
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

-(NSDictionary<NSString *, id> *)getParameterForCommerceEvent:(MPCommerceEvent *)commerceEvent andProduct:(MPProduct *)product withValue:(NSNumber *)value {
    NSMutableDictionary<NSString *, id> *parameters = [[NSMutableDictionary alloc] init];
    
    if (product.quantity) {
        [parameters setObject:product.quantity forKey:kFIRParameterQuantity];
    }
    if (product.sku) {
        [parameters setObject:product.sku forKey:kFIRParameterItemID];
    }
    if (product.name) {
        [parameters setObject:product.name forKey:kFIRParameterItemName];
    }
    if (product.category) {
        [parameters setObject:product.category forKey:kFIRParameterItemCategory];
    }
    if (product.price) {
        [parameters setObject:@(product.price.doubleValue * product.quantity.doubleValue) forKey:kFIRParameterValue];
        [parameters setObject:product.price forKey:kFIRParameterPrice];
    }
    if (commerceEvent.currency) {
        [parameters setObject:commerceEvent.currency forKey:kFIRParameterCurrency];
    }
    if (value) {
        [parameters setObject:value forKey:kFIRParameterValue];
    }
    if (commerceEvent.checkoutStep) {
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
    
    return parameters;
}

- (NSString * _Nullable)userIdForFirebase:(FilteredMParticleUser *)currentUser {
    NSString *userId;
    if (currentUser != nil && self.configuration[kMPFIRUserIdFieldKey] != nil) {
        NSString *key = self.configuration[kMPFIRUserIdFieldKey];
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
