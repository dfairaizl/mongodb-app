//
//  TerminalScript.h
//  MongoDB
//
//  Created by Dan Fairaizl on 1/22/15.
//  Copyright (c) 2015 TwentyBelow, LLC. All rights reserved.
//

#import "Terminal.h"

@interface MDBTerminalScript : NSObject

+ (MDBTerminalScript *)sharedInstance;
- (void)runCommand:(NSString *)cmd;

@end