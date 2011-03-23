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

#import <Foundation/Foundation.h>
#import "GTExceptionalMessage.h"


@interface GTExceptionalAPI : NSObject {
    
@private
    // Application identifier, e.g. product name
    NSString *applicationIdentifier;
    // Application version
    NSString *applicationVersion;
    // Path to the crash reporter internal data directory
    NSString *crashReportDirectory;
}

@property (nonatomic, retain) NSString *applicationIdentifier;
@property (nonatomic, retain) NSString *applicationVersion;
@property (nonatomic, retain) NSString *crashReportDirectory;

/**
 * Use this to retrieve the singleton instance of the API handler.
 *
 * Usage: ExceptionalAPI *api = [ExceptionalAPI sharedAPI];
 */
+ (GTExceptionalAPI *)sharedAPI;

/**
 * Call this once for your app to setup the exception handler.
 *
 * In an iOS environment this would fit in very well in the applicationDidFinishLaunching callback.
 */
- (void)setupExceptionHandling;

/**
 * Reports the exception to getexceptional API.
 *
 * exception - the exception, which should be reported. Must not be nil.
 * wait - YES, block the calling thread while sending the exception. NO, perform sending asynchronously.
 */
- (void)reportNSException:(NSException *)exception wait:(BOOL)wait;

/**
 * Reports the exception to getexceptional API.
 *
 * message - the wrapped exception, which should be reported. Must not be nil.
 * wait - YES, block the calling thread while sending the exception. NO, perform sending asynchronously.
 */
- (void)reportExceptionalMessage:(GTExceptionalMessage *)message wait:(BOOL)wait;

/**
 * Utility method, which returns the getexceptional.com reporting URL.
 * The URL is already setup with the API key from the exceptional.plist file
 *
 * e.g. http://api.getexceptional.com/api/errors?api_key=YOUR_API_KEY&protocol_version=6
 */
+ (NSURL *) exceptionalURL;

@end
