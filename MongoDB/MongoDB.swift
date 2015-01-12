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
    
    var processPipe = NSPipe()

    class var sharedServer: MongoDB {
        return _MongoDBSharedServer
    }
    
    func serverVersion() -> NSString {
        
        let (output, error) = NSTask.executeSyncTask("/usr/local/bin/mongod", withArguments: ["--version"])
        return output!
    }
    
    func startServer() {
        
        let manager = NSFileManager.defaultManager()
        let bundlePath = NSBundle.mainBundle().bundlePath
        let mongod = bundlePath.stringByAppendingPathComponent("Contents/MongoDB/2.6.6/bin/mongod")
        
        let db = self.databaseDirectory()!.path!
        let log = self.logFile()!.path!
        let args = ["--fork", "--dbpath=\(db)", "--logpath", "\(log)", "--logappend"]

        NSTask.executeAsyncTask(mongod, pipe: self.processPipe, withArguments: args, { (out: String) -> Void in
            NSLog("\(out)")
        })
    }
    
    func restartServer() {
        NSLog("starting server...")
    }
    
    func stopServer() {
        NSLog("starting server...")
    }
    
    func isRunning() -> Bool {
        return false
    }
    
    func databaseDirectory() -> NSURL? {
        return mongoDBDirectory("db")
    }
    
    func logDirectory() -> NSURL? {
        return mongoDBDirectory("log")
    }
    
    func logFile() -> NSURL? {
        return self.logDirectory()?.URLByAppendingPathComponent("mongodb.log")
    }
    
    private
    
    func mongoDBDirectory(directory: String) -> NSURL? {
        
        let manager = NSFileManager.defaultManager()
        
        let urls: NSArray = manager.URLsForDirectory(NSSearchPathDirectory.ApplicationSupportDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        var appSupportDir: NSURL?
        
        if urls.count > 0 {
            appSupportDir = urls.firstObject?.URLByAppendingPathComponent("com.twentybelow.mongodb/\(directory)") as NSURL!
            
            manager.createDirectoryAtURL(appSupportDir!, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        
        return appSupportDir
    }

}
