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
    
    func spawnProcess(#databasePath: String, logPath: String) -> Bool {

        if let mongod = self.mongodPath() {
            let args = ["--dbpath=\(databasePath)", "--logpath", "\(logPath)", "--logappend"]
            
            self.processPipe = NSPipe()
            
            self.process = NSTask.runProcess(mongod, pipe: self.processPipe!, withArguments: args, { (out: String) -> Void in
                // NOTE - There is no stdout from mongod when it started successfully in the foreground (output goes to log)
            })
            
            return true
        }
        
        return false
    }
    
    func isRunning() -> Bool {
        return self.process? != nil
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

                userDefaults.registerDefaults(defaultValues)
                NSUserDefaultsController.sharedUserDefaultsController().initialValues = defaultValues
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
        
        let itemReferences = itemReferencesInLoginItems()
    
        if let existingReference = itemReferences.existingReference {
            if startup {
                //NOOP - we are supposed to start on login and OSX has registered our app
            }
            else {
               self.removeStartupItem()
            }
        } else if startup {
            self.addStartupItem()
        }
    }
    
    func setUpdates() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let updates = defaults.boolForKey("autoUpdate")
        
        self.ensureUpdates(updates)
        self.autoUpdates = updates
    }
    
    func ensureUpdates(update: Bool) {
        
        if update {
            //14400
            //self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "checkForUpdate", userInfo: nil, repeats: true)
            
            //Run a check now just in case
            self.checkForUpdate()
        }
        else {
            self.updateTimer?.invalidate()
            self.updateTimer = nil
        }
    }
    
    func selectVersion() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        self.version = defaults.stringForKey("mongodbVersion")
        self.versions = defaults.arrayForKey("availableVersions") as Array<String>
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
    
    func mongodPath() -> String? {
        if let version = self.version {
            let bundlePath = NSBundle.mainBundle().bundlePath
            return bundlePath.stringByAppendingPathComponent("Contents/MongoDB/\(version)/bin/mongod")
        }
        
        return nil
    }
    
    func applicationIsInStartUpItems() -> Bool {
        return (itemReferencesInLoginItems().existingReference != nil)
    }
    
    func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItemRef?, lastReference: LSSharedFileListItemRef?) {
        
        var itemUrl : UnsafeMutablePointer<Unmanaged<CFURL>?> = UnsafeMutablePointer<Unmanaged<CFURL>?>.alloc(1)
        
        if let appUrl : NSURL = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
            let loginItemsRef = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileListRef?

            if loginItemsRef != nil {
                let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray

                if(loginItems.count > 0) {
                    let lastItemRef: LSSharedFileListItemRef = loginItems.lastObject as LSSharedFileListItemRef
                    
                    for var i = 0; i < loginItems.count; ++i {
                        
                        let currentItemRef: LSSharedFileListItemRef = loginItems.objectAtIndex(i) as LSSharedFileListItemRef
                        if LSSharedFileListItemResolve(currentItemRef, 0, itemUrl, nil) == noErr {
                            if let urlRef: NSURL =  itemUrl.memory?.takeRetainedValue() {

                                if urlRef.isEqual(appUrl) {
                                    return (currentItemRef, lastItemRef)
                                }
                            }
                        }
                    }
                    
                    //The application was not found in the startup list
                    return (nil, lastItemRef)
                }
                else {
                    let addatstart: LSSharedFileListItemRef = kLSSharedFileListItemBeforeFirst.takeRetainedValue()
                    
                    return(nil, addatstart)
                }
            }
        }
        
        return (nil, nil)
    }
    
    func addStartupItem() {
        
        let itemReferences = itemReferencesInLoginItems()
        let loginItemsRef = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileListRef?
        
        if loginItemsRef != nil {
            
            if let appUrl : CFURLRef = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
                LSSharedFileListInsertItemURL(loginItemsRef, itemReferences.lastReference, nil, nil, appUrl, nil, nil)
            }
        }
    }
    
    func removeStartupItem() {
        
        let itemReferences = itemReferencesInLoginItems()
        let loginItemsRef = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileListRef?
        
        if loginItemsRef != nil {

            if let itemRef = itemReferences.existingReference {
                LSSharedFileListItemRemove(loginItemsRef, itemRef);
            }
        }
    }
    
    func checkForUpdate() {
        NSLog("Checking for updates")
        
        //Access token 887c63214b45882b641b5d4e7a55f860e306b2a7
        let url = NSURL(string: "https://api.github.com/repos/dfairaizl/mongodb-app/releases")
        
        let request = NSMutableURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60)
        request.setValue("Basic ODg3YzYzMjE0YjQ1ODgyYjY0MWI1ZDRlN2E1NWY4NjBlMzA2YjJhNzp4LW9hdXRoLWJhc2lj", forHTTPHeaderField: "Authorization")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? NSArray
            
            if let latestRelease = json?[0] as? NSDictionary {
                if let latestVersion = latestRelease["tag_name"] as? String {
                    
                    if let currentVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
                        
                        if latestVersion > currentVersion {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.notifyOfUpdate(latestRelease)
                            })
                        }
                    }
                }
            }
        }
    }
    
    func notifyOfUpdate(versionData: NSDictionary) {
        let center = NSUserNotificationCenter.defaultUserNotificationCenter()
        let note = NSUserNotification()
        
        note.title = "New Version Available"
        note.informativeText = "A new version of MongoDB is available."
        note.hasActionButton = true
        note.actionButtonTitle = "Update"
        
        var infoDictionary = [NSObject: AnyObject]()
        infoDictionary.updateValue(versionData["name"]!, forKey: "releaseName")
        infoDictionary.updateValue(versionData["name"]!, forKey: "releaseName")
        
        if let assets = versionData["assets"] as? NSArray {
            if let asset = assets[0] as? NSDictionary {
                infoDictionary.updateValue(asset["browser_download_url"]!, forKey: "downloadURL")
            }
        }
        
        note.userInfo = infoDictionary
        
        let delegate = NSApplication.sharedApplication().delegate as AppDelegate
        center.delegate = delegate
        center.deliverNotification(note)
    }
}
