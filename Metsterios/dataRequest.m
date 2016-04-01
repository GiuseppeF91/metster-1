//
//  dataRequest.m
//  Metsterios
//
//  Created by Chelsea Green on 3/30/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

#import "dataRequest.h"
#import "Metsterios-Swift.h"

@implementation dataRequest

@synthesize returnedInfo = _returnedInfo;

NSString *myRequestString;
NSArray *keys;
NSArray *objects;
NSDictionary *jsonDictionary;
NSData *jsonData;
NSString *myString;

NSString *key = @"22";
NSString *email;
NSString *rid;
NSString *query;
NSString *event_id;
NSString *fb_id;
NSString *name;
NSString *latitude;
NSString *longitude;
NSString *event_name;
NSString *event_date;
NSString *event_time;
NSString *event_notes;
NSArray *event_members;
NSString *what;
NSString *movie_pref;
NSString *food_pref;


-(void) post_req{

    rid = _oper;
    email = _emailAddress;
    query = _search;
    event_id = _eventid;
    fb_id = _fbid;
    name = _name;
    latitude = _latitude;
    longitude = _longitude;
    event_name = _event_name;
    event_date = _event_date;
    event_time = _event_time;
    event_notes = _event_notes;
    event_members = _event_members;
    what = _what;
    movie_pref = _movie_pref;
    food_pref = food_pref;
    
    NSError * error = nil;
    
    if ([rid  isEqual: @"111002"]) //find in account
    {
        keys = [NSArray arrayWithObjects:@"email", nil];
        objects = [NSArray arrayWithObjects:email, nil];
    }
    
    if ([rid  isEqual: @"999000"]) //find food
    {
        keys = [NSArray arrayWithObjects:@"query", @"event_id", nil];
        objects = [NSArray arrayWithObjects:query, event_id, nil];
    }
    
    if ([rid isEqual: @"111000"]) //insert to account
    {
        keys = [NSArray arrayWithObjects:@"dev_id", @"email", @"fb_id", @"name", @"invites", @"hosted", @"joined", @"latitude", @"longitude", @"food_pref", @"moviepref", nil];
        objects = [NSArray arrayWithObjects:@"12er34", email, fb_id, name, @[@"none"], @[@"none"], @[@"none"], latitude, longitude, @"Chinese", @"Horror", nil];
    }
    
    if ([rid isEqual: @"111003"]) //update in account
        
    {
        keys = [NSArray arrayWithObjects:@"email", @"what", @"movie_pref", @"food_pref", nil];
        objects = [NSArray arrayWithObjects:email, what, movie_pref, food_pref, nil];
        
    }
    
    if ([rid isEqual: @"121000"]) //insert to events
    {
        keys = [NSArray arrayWithObjects:@"host_email", @"event_name", @"event_date", @"event_time", @"event_notes", @"event_members", nil];
        objects = [NSArray arrayWithObjects:email, event_name, event_date, event_time, event_notes, event_members, nil];
    }
    
    if ([rid isEqual: @"998000"]) //accept invite
    {
        keys = [NSArray arrayWithObjects:@"email", @"event_id", nil];
        objects = [NSArray arrayWithObjects:email, event_id, nil];
    }
    
    jsonDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&error];
    myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    myRequestString = [[NSString alloc] initWithFormat:@"operation=%@&key=%@&payload=%@", rid, key, myString];
    
    id result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"\n\n\n id for json==%@ \n\n\n\n\n",result);
    
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString:@"http://104.236.177.93:8888"]];
    
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody: myRequestData];
    NSURLResponse *response;
    NSError *err;
    NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&err];
    NSString* responseString = [[NSString alloc] initWithData:returnData encoding:NSNonLossyASCIIStringEncoding];
    
    _returnedInfo = responseString;
}

@end