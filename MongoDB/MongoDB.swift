//
//  MongoDB.swift
//  MongoDB
//
//  Created by Dan Fairaizl on 12/29/14.
//  Copyright (c) 2014 TwentyBelow, LLC. All rights reserved.
//

import Cocoa

private let _MongoDBSharedServer = MongoDB()

class MongoDB: NSObject {

    class var sharedServer: MongoDB {
        return _MongoDBSharedServer
    }
    
    func mongodVersion() -> NSString {
        
        let (output, error) = NSTask.executeSyncTask("/usr/local/bin/mongod", withArguments: ["--version"])
        return output!
    }
    
    func startServer() {
        NSLog("starting server...")
    }

}
