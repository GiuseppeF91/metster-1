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

-(void) post_req;

@end