//
//  UserModel.h
//  CoreDataDemo
//
//  Created by lzxuan on 15/9/6.
//  Copyright (c) 2015年 lzxuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserModel : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * age;

@end






