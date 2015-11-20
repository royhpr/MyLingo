//
//  GlobalSharingCentre.h
//  miceapps
//
//  Created by purong on 13/4/15.
//  Copyright (c) 2015 royhpr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HistoryModel.h"

@interface GlobalSharingCentre : NSObject

+ (GlobalSharingCentre*)sharedVariables;

+(void)agreeToTC;
+(NSString*)getAgreeToTC;
+(void)clearTC;

+(NSArray*)getHistoryData;
+(void)insertHistoryDataWithDrugName:(NSString*)drugName Timestamp:(NSString*)timestamp Latitude:(NSString*)latitude Longitude:(NSString*)longitude Address:(NSString*)address;
+(void)deleteHistoryDataWithDrugName:(NSString*)drugName Timestamp:(NSString*)timestamp;
+(NSString*)trimTheString:(NSString*)string;

@end
