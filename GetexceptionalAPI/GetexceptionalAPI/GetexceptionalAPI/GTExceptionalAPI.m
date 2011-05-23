/*
 * Author: Jörg Polakowski <jp@mobile-melting.de>
 *
 * Copyright (c) 2011 mobile melting GmbH
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#import "GTExceptionalAPI.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "GTExceptionalDeviceInfo.h"

#define NSDEBUG(msg, args...) {\
    NSLog(@"[ExceptionalAPI] " msg, ## args); \
}

/** 
 * @internal
 * CrashReporter cache directory name. 
 */
static NSString *GTCRASH_CACHE_DIR = @"com.mobilemelting.exceptional.data";

// private category
@interface GTExceptionalAPI (Private)

- (id) initWithBundle:(NSBundle *)bundle;
- (id) initWithApplicationIdentifier:(NSString *)identifier appVersion:(NSString *)version;

- (void)exceptionReportingRequestFinished:(ASIHTTPRequest *)request;
- (void)exceptionReportingRequestFailed:(ASIHTTPRequest *)request;
@end
    
    
@implementation GTExceptionalAPI

static GTExceptionalAPI *sharedSingleton = nil;

@synthesize applicationIdentifier, applicationVersion, deviceName, systemVersion,
crashReportDirectory;

/**
 * Return the application's crash reporter instance.
 */
+ (GTExceptionalAPI *)sharedAPI {
    if (sharedSingleton == nil) {
        sharedSingleton = [[GTExceptionalAPI alloc] initWithBundle:[NSBundle mainBundle]];
    }
    return sharedSingleton;
}

void exceptionHandler(NSException *exception) {
    [[GTExceptionalAPI sharedAPI] reportNSException:exception wait:YES];
}

- (void)setupExceptionHandling {
    // Change top-level exception handler to report exceptions to 'getexceptional'
    NSSetUncaughtExceptionHandler(&exceptionHandler);
}

- (void)reportNSException:(NSException *)exception wait:(BOOL)wait {
    GTExceptionalMessage *message = [[GTExceptionalMessage alloc] initWithException:exception];
    [self reportExceptionalMessage:message wait:wait];
    [message release];
}

- (void)reportExceptionalMessage:(GTExceptionalMessage *)message wait:(BOOL)wait {
    
    NSDictionary *exDict = [NSDictionary dictionaryWithObjectsAndKeys:
                            [message message], @"message",
                            [message exceptionClassName], @"exception_class",
                            [message backtrace], @"backtrace",
                            [message occuredAt], @"occurred_at", nil];

    // "env"
    NSDictionary *envDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.applicationIdentifier, @"application_identifier",
                             self.applicationVersion, @"application_version",
                             self.deviceName, @"device_name",
                             self.systemVersion, @"device_version", nil];
    
    // "application_environment"
    NSDictionary *appDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"objective-c", @"language",
                             @"Apple iOS", @"framework",
                             envDict, @"env",
                             @"", @"application_root_directory", nil];
    
    // "client"
    NSDictionary *clientDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"getexceptional-ios-api-wrapper", @"name",
                                @"1.0", @"version",
                                @"6", @"protocol_version", nil];    
    
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          exDict, @"exception",
                          appDict, @"application_environment",
                          clientDict, @"client", nil];
	
	SBJsonWriter *parser = [[SBJsonWriter alloc] init];	
	NSString *exceptionData = [parser stringWithObject:dict];
	[parser release];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[GTExceptionalAPI exceptionalURL]];
	[request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request appendPostData:[exceptionData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setShouldCompressRequestBody:YES]; // gzip the POST data
    [request setAllowCompressedResponse:YES];
	[request setShouldRedirect:NO];
    [request setDelegate:self];
    if (wait) {
        [request startSynchronous];
    }
    else {
        [request setDidFinishSelector:@selector(exceptionReportingRequestFinished:)];
        [request setDidFailSelector:@selector(exceptionReportingRequestFailed:)];	
        [request startAsynchronous];
    }
}

+ (NSURL *) exceptionalURL {    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"exceptional" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString *apiKey = [dict valueForKey:@"API_KEY"];
    NSString *apiBaseUrl = [dict valueForKey:@"API_BASE_URL"];
    NSString *apiUrlPath = [NSString stringWithFormat:@"%@?api_key=%@&protocol_version=6", 
                            apiBaseUrl, apiKey];
    
    return [NSURL URLWithString:apiUrlPath];
}

@end


/**
 * @internal
 *
 * Private Methods
 */
@implementation GTExceptionalAPI (Private)

/**
 * @internal
 * 
 * Initialize with the provided bundle's ID and version.
 */
- (id) initWithBundle: (NSBundle *) bundle {
    NSString *bundleIdentifier = [bundle bundleIdentifier];
    NSString *bundleVersion = [[bundle infoDictionary] objectForKey: (NSString *) kCFBundleVersionKey];
    
    /* Verify that the identifier is available */
    if (bundleIdentifier == nil) {
        const char *progname = getprogname();
        if (progname == NULL) {
            [NSException raise:@"ExceptionalAPI" format:@"Can not determine process identifier or process name"];
            [self release];
            return nil;
        }
        NSDEBUG(@"Warning -- bundle identifier, using process name %s", progname);
        bundleIdentifier = [NSString stringWithUTF8String:progname];
    }
    /* Verify that the version is available */
    if (bundleVersion == nil) {
        NSDEBUG(@"Warning -- bundle version unavailable");
        bundleVersion = @"";
    }
    return [self initWithApplicationIdentifier:bundleIdentifier appVersion:bundleVersion];
}

/**
 * @internal
 *
 * This is the designated initializer, but it is not intended to be called externally.
 */
- (id) initWithApplicationIdentifier:(NSString *)identifier appVersion:(NSString *)version {
    /* Only allow one instance to be created, no matter what */
    if (sharedSingleton != NULL) {
        [self release];
        return sharedSingleton;
    }
    /* Initialize our superclass */
    if ((self = [super init]) == nil) {
        return nil;
    }    
    // Save application ID, version and device name
    self.applicationIdentifier = identifier;
    self.applicationVersion = version;
    self.deviceName = [GTExceptionalDeviceInfo platformString];
    self.systemVersion = [[UIDevice currentDevice] systemVersion];
    
    /* No occurances of '/' should ever be in a bundle ID, but just to be safe, we escape them */
    NSString *appIdPath = [applicationIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDir = [paths objectAtIndex:0];
    self.crashReportDirectory = [[cacheDir stringByAppendingPathComponent:GTCRASH_CACHE_DIR]
                                 stringByAppendingPathComponent:appIdPath];
    return self;
}

#pragma ASIHTTPRequest delegate methods

- (void)exceptionReportingRequestFinished:(ASIHTTPRequest *)request {
	NSLog(@"Exception has been reported ..");
    
    NSLog(@"Status Code: %d", [request responseStatusCode]);
    NSLog(@"Request Message: %@", [request responseStatusMessage]);
}

- (void)exceptionReportingRequestFailed:(ASIHTTPRequest *)request {	
	// TODO: handle request failure
	NSLog(@"Exception Reporting failed ...");
}

@end
