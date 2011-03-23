//
//  NSDate+StringParsing.h
//  storytude
//
//  Created by Jörg Polakowski on 08/03/11.
//  Copyright 2011 mobile melting Gmbh. All rights reserved.
//
// Category for handling API dates, especially in "en_US_POSIX" locale
// http://stackoverflow.com/questions/4418470/inconsistent-behaviour-with-nsdateformatter-on-two-different-devices
//
// Apple has a good tech note, which explains how to work with Internet dates:
// http://developer.apple.com/library/ios/#qa/qa2010/qa1480.html
//

#import <Foundation/Foundation.h>


@interface NSDate (StringParsing)

//
// The dates returned by the Rails API were in the format '2010-11-28T20:30:49Z' and were in UTC.
// The code first checks that the date string is not nil, then replaces the 'Z' at the end of the 
// timestamp with a zero UTC offset string that we can match using NSDateFormatter.
//
+ (NSDate *)dateWithISO8601String:(NSString *)dateString;

/**
 * Uses the "en_US_POSIX" locale for the data formatter.
 */
+ (NSDate *)dateFromString:(NSString *)dateString 
                withFormat:(NSString *)dateFormat;

/**
 * Converts a date into a ISO8601 conform string.
 */
+ (NSString *)strFromISO8601:(NSDate *)date;

@end
