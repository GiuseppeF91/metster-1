//
//  dataRequest.h
//  Metsterios
//
//  Created by Chelsea Green on 3/30/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface dataRequest : NSObject
{
    NSString *_returnedInfo;
}

@property (strong, nonatomic) NSString *returnedInfo;

@property (strong, nonatomic) NSString* oper;
@property (strong, nonatomic) NSString* emailAddress;
@property (strong, nonatomic) NSString* search;
@property (strong, nonatomic) NSString* eventid;

@property (strong, nonatomic) NSString* fbid;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* latitude;
@property (strong, nonatomic) NSString* longitude;
@property (strong, nonatomic) NSString* event_name;
@property (strong, nonatomic) NSString* event_date;
@property (strong, nonatomic) NSString* event_time;
@property (strong, nonatomic) NSString* event_notes;
@property (strong, nonatomic) NSArray* event_members;
@property (strong, nonatomic) NSString* what;
@property (strong, nonatomic) NSString* movie_pref;
@property (strong, nonatomic) NSString* food_pref;

-(void) post_req;

@end