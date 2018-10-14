/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

#import "OBCallsCache.h"
#import "OBConfig.h"

@class ZCNConnect;

typedef void (^OBDeferredExecution)(void);

/**
 The OBMainController class provides with global-level information and configuration of the Outbound library.
 This object doesn't do much at the moment besides holding an instance of OBCallsCache, but it is intended to serve as a basis for future additions to the SDK.
 */
@interface OBMainController : NSObject

/**-----------------------------------------------------------------------------
 * @name Properties
 * -----------------------------------------------------------------------------
 */

/**
 @abstract The host app's API key, provided by the -initWithPrivateKey: method.
 */
@property (nonatomic) NSString *apiKey;


@property (nonatomic) ZCNConnect *connect;

/**
 @abstract When the debug option is enabled, the OBDebug() macro will print a message to the console.
 This option can be enabled by the host app using Outbound -setDebug:
 */
@property (nonatomic) BOOL debug;

/**
 @abstract An instance of OBCallsCache to manage network calls.
 */
@property (nonatomic) OBCallsCache *callsCache;

/**
 @abstract An instance of the sdk config. Tells us when to ask for permissions, etc.
 */
@property (nonatomic) OBConfig *config;

/**-----------------------------------------------------------------------------
 * @name Public methods
 * -----------------------------------------------------------------------------
 */

/**
 @abstract Returns the shared `OBMainController` instance, creating it if necessary.
 @return The shared `OBMainController` instance.
 */
+ (OBMainController *)sharedInstance;

/**
 @abstract
 @param apiKey The host app's Outbound API key.
 */
- (void)initWithPrivateKey:(NSString *)apiKey;

- (void)checkForSdkInitAndExecute:(OBDeferredExecution)block;

- (void)registerDeviceToken:(NSData *)deviceToken;

- (void)promptForPermissions;

@end
