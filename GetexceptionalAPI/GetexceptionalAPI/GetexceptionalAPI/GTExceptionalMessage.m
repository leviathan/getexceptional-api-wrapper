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

#import "GTExceptionalMessage.h"
#import "GTExceptionalAPI.h"

@implementation GTExceptionalMessage

@synthesize message, exceptionClassName, backtrace, occuredAt;

- (void)dealloc {
    [message release];
    [exceptionClassName release];
    [backtrace release];
    [occuredAt release];
    [super dealloc];
}

- (id)init {
	self = [super init];
	if (self != nil) {
        // additional init stuff here
        ISO8601DateFormatter *isoFormatter = [[ISO8601DateFormatter alloc] init];
        [isoFormatter setIncludeTime:YES];
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        self.occuredAt = [isoFormatter stringFromDate:[NSDate date] timeZone:timeZone];
        [isoFormatter release];
    }
	return self;
}

- (id)initWithMessage:(NSString *)exMessage 
       exceptionClass:(NSString *)exClass 
            backtrace:(NSArray *)exBacktrace {
    
    GTExceptionalMessage *exceptionalMessage = (GTExceptionalMessage *) [self init];
    
    self.message = exMessage;
    self.exceptionClassName = exClass;
    if (exBacktrace == nil) {
        self.backtrace = [NSThread callStackSymbols];
    }
    else {
        self.backtrace = exBacktrace;
    }
    
    return exceptionalMessage;
}

- (id)initWithException:(NSException *)exception {
    return [self initWithMessage:[exception reason] exceptionClass:[exception name] backtrace:[exception callStackSymbols]];    
}

@end
