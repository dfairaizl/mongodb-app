//
//  TerminalScript.m
//  MongoDB
//
//  Created by Dan Fairaizl on 1/22/15.
//  Copyright (c) 2015 TwentyBelow, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TerminalScript.h"

@interface MDBTerminalScript ()

@property (strong, nonatomic) TerminalApplication *terminalApp;

@end

@implementation MDBTerminalScript

+ (MDBTerminalScript *)sharedInstance {
    
    static MDBTerminalScript *sharedTerminalScript = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTerminalScript = [[self alloc] init];
    });
    
    return sharedTerminalScript;
}

- (id)init {

    if(self = [super init]) {
        
        NSURL *terminalURL = [NSURL fileURLWithPath:@"/Applications/Utilities/Terminal.app"];
        self.terminalApp = [SBApplication applicationWithURL:terminalURL];
    }
    
    return self;
}

- (void)runCommand:(NSString *)cmd {
    
    TerminalWindow *termWindow = [self.terminalApp.windows lastObject];
    
    [self.terminalApp activate];
    [self.terminalApp doScript:cmd in:[termWindow.tabs firstObject]];
    
}

@end