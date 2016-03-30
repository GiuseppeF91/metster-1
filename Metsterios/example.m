//
//  example.m
//  Metsterios
//
//  Created by Chelsea Green on 3/30/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

#import <Foundation/Foundation.h>

void post_req()

{
    NSString *oper = @"999000";
    NSString *key = @"223";
    NSString *query = @"sushi";
    NSString *event_id = @"10103884620845432--event--1";
    NSError * error = nil;
    
    NSString *myRequestString = [[NSString alloc] initWithFormat:@"operation=%@&key=%@&payload=%@", oper, key, query, event_id];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString:@"http://104.236.177.93:8888"]];
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody: myRequestData];
    NSURLResponse *response;
    NSError *err;
    NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&err];
    NSString *content = [NSString stringWithUTF8String:[returnData bytes]];
    NSError *e = nil;
    NSData *jData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:jData options: NSJSONReadingMutableContainers error: &e];
    
    id<NSObject> value = JSON[@"response"];
    
    NSLog(@"responseData: %@", JSON);
    NSLog(@"payData: %@", value);
    NSString* responseString = [[NSString alloc] initWithData:returnData encoding:NSNonLossyASCIIStringEncoding];
    
    if ([content isEqualToString:responseString])
    {
        NSLog(@"responseData: %@", content);
    }
}