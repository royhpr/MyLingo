//
//  HistoryModel.h
//  ScanYourDrug
//
//  Created by royhpr on 19/11/15.
//  Copyright © 2015 royhpr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryModel : NSObject

@property(nonatomic, strong)NSString *drugName;
@property(nonatomic, strong)NSString *timestamp;
@property(nonatomic, strong)NSString *latitude;
@property(nonatomic, strong)NSString *longitude;
@property(nonatomic, strong)NSString *address;

@end
