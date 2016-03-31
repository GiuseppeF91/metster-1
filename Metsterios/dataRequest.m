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

NSString *key = @"22";
NSString *email;
NSString *rid;

-(void) post_req{

    rid = _oper;
    email = _emailAddress;
    
        NSError * error = nil;
        NSArray *keys = [NSArray arrayWithObjects:@"email", nil];
        NSArray *objects = [NSArray arrayWithObjects:@"navimn1991@gmail.com", nil];
        NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&error];
        NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        id result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        
        NSLog(@"\n\n\n id for json==%@ \n\n\n\n\n",result);
        
        NSString *myRequestString = [[NSString alloc] initWithFormat:@"operation=%@&key=%@&payload=%@", rid, key, myString];
        
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

@end