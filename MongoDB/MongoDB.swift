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
    
    var process: NSTask?
    var processPipe: NSPipe?

    class var sharedServer: MongoDB {
        return _MongoDBSharedServer
    }
    
    func serverVersion() -> NSString {
      
        let (output, error) = NSTask.executeSyncTask(self.mongodPath(), withArguments: ["--version"])
        return output!
    }
    
    func startServer() {
       
        let mongod = self.mongodPath()
        
        let db = self.databaseDirectory()!.path!
        let log = self.logFile()!.path!
        let args = ["--dbpath=\(db)", "--logpath", "\(log)", "--logappend"]
        
        self.processPipe = NSPipe()

        self.process = NSTask.runProcess(mongod, pipe: self.processPipe!, withArguments: args, { (out: String) -> Void in
            // NOTE - There is no stdout from mongod when it started successfully in the foreground (output goes to log)
            NSLog("\(out)")
        })
        
        NSNotificationCenter.defaultCenter().postNotificationName("ServerStartedSuccessfullyNotification", object: nil)
    }
    
    func restartServer() {
        NSLog("starting server...")
    }
    
    func stopServer() {
        self.process?.terminate()
        self.process = nil
        NSNotificationCenter.defaultCenter().postNotificationName("ServerStoppedSuccessfullyNotification", object: nil)
    }
    
    func isRunning() -> Bool {
        return self.process? != nil
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
    
    func mongodPath() -> String {
        
        let bundlePath = NSBundle.mainBundle().bundlePath
        return bundlePath.stringByAppendingPathComponent("Contents/MongoDB/2.6.6/bin/mongod")
    }
    
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
