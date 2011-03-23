//
//  NSDate+StringParsing.m
//  storytude
//
//  Created by Jörg Polakowski on 08/03/11.
//  Copyright 2011 mobile melting Gmbh. All rights reserved.
//

#import "NSDate+StringParsing.h"

#define ISO_TIMEZONE_UTC_FORMAT     @"Z"
#define ISO_TIMEZONE_OFFSET_FORMAT  @"%+02d%02d"

@implementation NSDate (StringParsing)

+ (NSDate *)dateWithISO8601String:(NSString *)dateString {
	if (!dateString) return nil;
	if ([dateString hasSuffix:@"Z"]) {
		dateString = [[dateString substringToIndex:(dateString.length-1)] 
					  stringByAppendingString:@"-0000"];
	}
	return [self dateFromString:dateString withFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
}

+ (NSDate *)dateFromString:(NSString *)dateString 
                withFormat:(NSString *)dateFormat {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:dateFormat];
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	[dateFormatter setLocale:locale];
	[locale release];
	NSDate *date = [dateFormatter dateFromString:dateString];
	[dateFormatter release];
	return date;
}

+ (NSString *)strFromISO8601:(NSDate *)date {
    static NSDateFormatter* sISO8601 = nil;
    
    if (!sISO8601) {
        sISO8601 = [[NSDateFormatter alloc] init];
        
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        int offset = [timeZone secondsFromGMT];
        
        NSMutableString *strFormat = [NSMutableString stringWithString:@"yyyyMMdd'T'HH:mm:ss"];
        offset /= 60; //bring down to minutes
        if (offset == 0) {
            [strFormat appendString:ISO_TIMEZONE_UTC_FORMAT];
        }
        else {
            [strFormat appendFormat:ISO_TIMEZONE_OFFSET_FORMAT, offset / 60, offset % 60];
        }
        [sISO8601 setTimeStyle:NSDateFormatterFullStyle];
        [sISO8601 setDateFormat:strFormat];
    }
    return[sISO8601 stringFromDate:date];
}

@end
