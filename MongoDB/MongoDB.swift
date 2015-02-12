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
    
    var databasePath: String?
    var logPath: String?
    
    override init() {
        super.init()
        
        // Setup defaults to be read from if needed
        self.setDefaults()
        
        // Read the runtime values from defaults to start server
        self.initDatabase()
        self.initLog()
    }

    class var sharedServer: MongoDB {
        return _MongoDBSharedServer
    }
    
    func serverVersion() -> NSString {
      
        let (output, error) = NSTask.executeSyncTask(self.mongodPath(), withArguments: ["--version"])
        return output!
    }
    
    func startServer() {
       
        let mongod = self.mongodPath()
        
        let db = self.databasePath!
        let log = self.logPath!
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

    private
    
    func setDefaults() {
        
        if let path = NSBundle.mainBundle().pathForResource("defaults", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
                let userDefaults = NSUserDefaults.standardUserDefaults()

                var defaultValues = NSMutableDictionary()
                defaultValues.setValue(self.defaultDatabaseDirectory(), forKey: "databasePath")
                defaultValues.setValue(self.defaultLogDirectory(), forKey: "logPath")
                defaultValues.setValue(true, forKey: "autoStartup")
                defaultValues.setValue(true, forKey: "autoUpdate")

                userDefaults.registerDefaults(defaultValues)
                
                NSUserDefaultsController.sharedUserDefaultsController().initialValues = defaultValues
            }
        }
    }
    
    func defaultDatabaseDirectory() -> String? {
        return mongoDBDirectory("db")?.path
    }
    
    func defaultLogDirectory() -> String? {
        return mongoDBDirectory("log")?.URLByAppendingPathComponent("mongodb.log").path
    }
    
    func initDatabase()  {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        self.databasePath = defaults.stringForKey("databasePath")
    }
    
    func initLog() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        self.logPath = defaults.stringForKey("logPath")
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
    
    func mongodPath() -> String {
        
        let bundlePath = NSBundle.mainBundle().bundlePath
        return bundlePath.stringByAppendingPathComponent("Contents/MongoDB/2.6.6/bin/mongod")
    }
}
