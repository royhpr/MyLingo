//
//  GlobalSharingCentre.m
//  miceapps
//
//  Created by purong on 13/4/15.
//  Copyright (c) 2015 royhpr. All rights reserved.
//

#import "GlobalSharingCentre.h"

@implementation GlobalSharingCentre

static GlobalSharingCentre *shared = NULL;

- (id)init{
    if (self = [super init]){

    }
    return self;
}

+ (GlobalSharingCentre*)sharedVariables;{
    if (!shared || shared == NULL){
        // allocate the shared instance, because it hasn't been done yet
        shared = [[GlobalSharingCentre alloc] init];
    }
    return shared;
}

+(void)agreeToTC{
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName =  @"agree";
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    NSMutableDictionary* agreeRecord = [NSMutableDictionary dictionaryWithContentsOfFile:fileAtPath];
    if (!agreeRecord) {
        agreeRecord = [NSMutableDictionary dictionary];
    }
    
    [agreeRecord setObject:@"1" forKey:@"agree"];
    [agreeRecord writeToFile:fileAtPath atomically:NO];
}

+(NSString*)getAgreeToTC{
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName =  @"agree";
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    NSMutableDictionary* agreeRecord = [NSMutableDictionary dictionaryWithContentsOfFile:fileAtPath];
    if (!agreeRecord) {
        return nil;
    }
    
    return [agreeRecord objectForKey:@"agree"];
}

+(void)clearTC{
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName =  @"agree";
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    NSMutableDictionary* agreeRecord = [NSMutableDictionary dictionaryWithContentsOfFile:fileAtPath];
    
    [agreeRecord removeAllObjects];
    [agreeRecord writeToFile:fileAtPath atomically:NO];
}


+(NSArray*)getHistoryData{
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName =  @"history";
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    NSMutableDictionary* historyRecord = [NSMutableDictionary dictionaryWithContentsOfFile:fileAtPath];
    
    if(!historyRecord){
        return nil;
    }
    
    NSMutableArray *historyList = [[NSMutableArray alloc]init];
    
    //key: drugname@@@@timestamp
    //value: latitude@@@@longitude@@@@address
    for(NSString *key in historyRecord){
        HistoryModel *history = [[HistoryModel alloc]init];
        NSString *value = [historyRecord objectForKey:key];
        
        //drugname, timestamp
        NSArray *keyItems = [key componentsSeparatedByString:@"@@@@"];
        [history setDrugName:[keyItems objectAtIndex:0]];
        [history setTimestamp:[keyItems objectAtIndex:1]];
        
        //latitude, longitude, address
        NSArray *valueItems = [value componentsSeparatedByString:@"@@@@"];
        if(valueItems.count == 3){
            [history setLatitude:[valueItems objectAtIndex:0]];
            [history setLongitude:[valueItems objectAtIndex:1]];
            [history setAddress:[valueItems objectAtIndex:2]];
        }
        [historyList addObject:history];
    }
    return [NSArray arrayWithArray:historyList];
}

+(void)insertHistoryDataWithDrugName:(NSString*)drugName Timestamp:(NSString*)timestamp Latitude:(NSString*)latitude Longitude:(NSString*)longitude Address:(NSString*)address{
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName =  @"history";
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    NSMutableDictionary* historyRecord = [NSMutableDictionary dictionaryWithContentsOfFile:fileAtPath];
    if (!historyRecord) {
        historyRecord = [NSMutableDictionary dictionary];
    }
    
    NSString *key = [[NSString alloc]initWithFormat:@"%@@@@@%@", drugName, timestamp];
    NSString *value = [NSString stringWithFormat:@"%@_%@_%@",
                       latitude == nil ? @"@" : latitude,
                       longitude == nil ? @"@" : longitude,
                       address == nil || [address isEqual:[NSNull null]] ? @"@" : [self trimTheString:address]];
    
    if(latitude != nil && longitude == nil && address == nil){
        value = [[NSString alloc]initWithFormat:@"%@@@@@%@@@@@%@", latitude, longitude, address];
    }
    
    [historyRecord setObject:value forKey:key];
    [historyRecord writeToFile:fileAtPath atomically:NO];
}

+(void)deleteHistoryDataWithDrugName:(NSString*)drugName Timestamp:(NSString*)timestamp{
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName =  @"history";
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    NSMutableDictionary* historyRecord = [NSMutableDictionary dictionaryWithContentsOfFile:fileAtPath];
    
    if(historyRecord == nil){
        return;
    }
    
    NSString *key = [NSString stringWithFormat:@"%@@@@@%@", drugName, timestamp];
    
    [historyRecord removeObjectForKey:key];
    [historyRecord writeToFile:fileAtPath atomically:NO];
}

+(NSString*)trimTheString:(NSString*)string{
    return [string stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceCharacterSet]];
}

- (void)dealloc{
    NSLog(@"Deallocating singleton...");
}

@end
