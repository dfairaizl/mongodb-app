//
//  MongoDB.swift
//  MongoDB
//
//  Created by Dan Fairaizl on 12/29/14.
//  Copyright (c) 2014 TwentyBelow, LLC. All rights reserved.
//

import Cocoa
import ServiceManagement

private let _MongoDBSharedServer = MongoDB()

class MongoDB: NSObject {
    
    var process: NSTask?
    var processPipe: NSPipe?
    
    var databasePath: String?
    var logPath: String?
    var port: String = "27017"
    var runOnStartup: Bool?
    var autoUpdates: Bool?
    var updateTimer: NSTimer?
    var version: String?
    var versions: Array<String> = []
    
    override init() {
        super.init()
        
        // Setup defaults to be read from if needed
        self.setDefaults()
        
        // Read the runtime values from defaults to start server
        self.initDatabase()
        self.initLog()
        self.setStartup()
        self.setUpdates()
        self.selectVersion()
    }

    class var sharedServer: MongoDB {
        return _MongoDBSharedServer
    }
    
    func serverVersion() -> NSString? {
        if let mongod = self.mongodPath() {
            let (output, error) = NSTask.executeSyncTask(mongod, withArguments: ["--version"])
            return output!
        }
        
        return nil
    }
    
    func currentVersion() -> String? {
        return self.version
    }
    
    func latestVersion() -> String {
        return self.versions[0]
    }
    
    func hasVersionAvailable(version: String) -> Bool {
        
        if contains(self.versions, version) {
            let bundlePath = NSBundle.mainBundle().bundlePath
            let fileManager = NSFileManager.defaultManager()
            let binPath = bundlePath.stringByAppendingPathComponent("Contents/MongoDB/\(version)")
            var directory: ObjCBool = false
            
            return fileManager.fileExistsAtPath(binPath, isDirectory: &directory) && directory
        }
        
        return false
    }
    
    func startServer() {
        
        if let db = self.databasePath {
            if let log = self.logPath {
                
                if self.spawnProcess(databasePath: db, logPath: log) {
                
                    NSNotificationCenter.defaultCenter().postNotificationName("ServerStartedSuccessfullyNotification", object: nil)
                }
            }
        }
    }
    
    func restartServer() {
        self.process?.terminate()
        self.process = nil
        
        self.selectVersion()
        self.initDatabase()
        self.initLog()
        
        if let db = self.databasePath {
            if let log = self.logPath {
                
                if self.spawnProcess(databasePath: db, logPath: log) {
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("ServerRestartedSuccessfullyNotification", object: nil)
                }
            }
        }
    }
    
    func stopServer() {
        self.process?.terminate()
        self.process = nil
        
        NSNotificationCenter.defaultCenter().postNotificationName("ServerStoppedSuccessfullyNotification", object: nil)
    }
    
    func isRunning() -> Bool {
        if let process = self.process {
            return true
        }
        else {
            return false
        }
    }
    
    func defaultDatabaseDirectory() -> String? {
        return mongoDBDirectory("db")?.path
    }
    
    func defaultLogDirectory() -> String? {
        return mongoDBDirectory("log")?.path
    }
    
    func enabledOnStartup() -> Bool {
        return self.runOnStartup!
    }

    func runOnStartup(run: Bool) {
        self.ensureStartup(run)
        self.runOnStartup = run
    }
    
    func enabledUpdates() -> Bool {
        return self.autoUpdates!
    }
    
    func scheduleUpdates(enabled: Bool) {
        self.ensureUpdates(enabled)
        self.autoUpdates = enabled
    }
    
    func mongodPath() -> String? {
        if let version = self.version {
            let bundlePath = NSBundle.mainBundle().bundlePath
            return bundlePath.stringByAppendingPathComponent("Contents/MongoDB/\(version)/bin/mongod").stringByStandardizingPath
        }
        
        return nil
    }
    
    func mongoPath() -> String? {
        if let version = self.version {
            let bundlePath = NSBundle.mainBundle().bundlePath
            return bundlePath.stringByAppendingPathComponent("Contents/MongoDB/\(version)/bin/mongo").stringByStandardizingPath
        }
        
        return nil
    }
    
    // MARK: Settings
    func preferenceForKey(key: String) -> String? {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.stringForKey(key)
    }
    
    func preferencesForKey(key: String) -> Array<AnyObject>? {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.arrayForKey(key)
    }
    
    func setPreference(value: String, forKey key: String) {
        let defaults = NSUserDefaults.standardUserDefaults()

        defaults.setValue(value, forKey: key)
        defaults.synchronize()
    }

    // MARK: Private Methods
    private
    
    func spawnProcess(#databasePath: String, logPath: String) -> Bool {
        
        //Check for presence of fs lock file
        if self.lockFilePresent(databasePath) && self.unsafeShutdown(databasePath) {

            //Clean up and notify?
            if let error = self.removeLockFile(databasePath) {
                NSLog("Error removing lock file!")
            }
        }
        
        if let mongod = self.mongodPath() {
            let args = ["--dbpath=\(databasePath)", "--logpath", "\(logPath)", "--port", self.port, "--logappend"]
            
            self.processPipe = NSPipe()
            
            self.process = NSTask.runProcess(mongod, pipe: self.processPipe!, withArguments: args, completion: { (out: String) -> Void in
                // NOTE - There is no stdout from mongod when it started successfully in the foreground (output goes to log)
            })
            
            return true
        }
        
        return false
    }
    
    func lockFilePresent(databasePath: NSString) -> Bool {
        
        let fileManager = NSFileManager.defaultManager()
        let lockFile = databasePath.stringByAppendingPathComponent("mongod.lock")
        
        return fileManager.fileExistsAtPath(lockFile)
    }
    
    func unsafeShutdown(databasePath: NSString) -> Bool {
     
        let fileManager = NSFileManager.defaultManager()
        let lockFile = databasePath.stringByAppendingPathComponent("mongod.lock")
        var error: NSError?
        
        if let attributes: NSDictionary = fileManager.attributesOfItemAtPath(lockFile, error: &error) {
            return attributes.fileSize() > 0
        }
        
        return false
    }
    
    func removeLockFile(databasePath: NSString) -> NSError? {

        var error: NSError?
        let fileManager = NSFileManager.defaultManager()
        let lockFile = databasePath.stringByAppendingPathComponent("mongod.lock")
        
        fileManager.removeItemAtPath(lockFile, error: &error)
        
        return error
    }
    
    func setDefaults() {
        
        if let path = NSBundle.mainBundle().pathForResource("defaults", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
                let userDefaults = NSUserDefaults.standardUserDefaults()

                var defaultValues = NSMutableDictionary()
                
                // Merge in pList settings
                defaultValues.setValue(dict["mongodbVersion"], forKey: "mongodbVersion")
                defaultValues.setValue(dict["availableVersions"], forKey: "availableVersions")
                defaultValues.setValue(dict["autoStartup"], forKey: "autoStartup")
                defaultValues.setValue(dict["autoUpdate"], forKey: "autoUpdate")
                
                // Add runtime settings
                defaultValues.setValue(self.defaultDatabaseDirectory(), forKey: "databasePath")
                defaultValues.setValue(self.defaultLogDirectory(), forKey: "logPath")

                userDefaults.registerDefaults(defaultValues as [NSObject : AnyObject])
                NSUserDefaultsController.sharedUserDefaultsController().initialValues = defaultValues as [NSObject : AnyObject]
            }
        }
    }
    
    func initDatabase() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        self.databasePath = defaults.stringForKey("databasePath")
    }
    
    func initLog() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let defaultLogPath = defaults.stringForKey("logPath")
        
        if let logStringPath = defaultLogPath {
            let basePath =  NSURL.fileURLWithPath(logStringPath, isDirectory: true)
            self.logPath = basePath!.URLByAppendingPathComponent("mongodb.log").path
        }
    }
    
    func setStartup() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let startup = defaults.boolForKey("autoStartup")

        self.ensureStartup(startup)
        self.runOnStartup = startup
    }
    
    func ensureStartup(startup: Bool) {
    
        if self.startupOnLogin() {
            if startup {
                //NOOP - helper app set to start on login
            }
            else {
               self.removeStartupItem()
            }
        } else if startup {
            self.addStartupItem()
        }
    }
    
    func startupOnLogin() -> Bool {
        
        return true
    }
    
    func addStartupItem() {
        
        let bundleURL = NSBundle.mainBundle().bundleURL
        let helperURL = bundleURL.URLByAppendingPathComponent("Contents/Library/LoginItems/MongoDBHelper.app")
        let ref: CFURL = helperURL as CFURL!
        
//        if LSRegisterURL(helperURL as? CFURL, true) {
//            
//        }
    }
    
    func removeStartupItem() {
        
    }
    
    func setUpdates() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let updates = defaults.boolForKey("autoUpdate")
        
        self.ensureUpdates(updates)
        self.autoUpdates = updates
    }
    
    func ensureUpdates(update: Bool) {
        
        if update {
            //self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "checkForUpdate", userInfo: nil, repeats: true)
            
            //Run a check now just in case
            //self.checkForUpdate()
        }
        else {
            self.updateTimer?.invalidate()
            self.updateTimer = nil
        }
    }
    
    func selectVersion() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        self.version = defaults.stringForKey("mongodbVersion")
        self.versions = defaults.arrayForKey("availableVersions") as! Array<String>
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
