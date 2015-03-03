//
//  ConnectionsViewController.swift
//  MongoDB
//
//  Created by Dan Fairaizl on 2/11/15.
//  Copyright (c) 2015 TwentyBelow, LLC. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController, DownloadDelegate {
    
    @IBOutlet weak var changeVersionButton: NSButton!
    @IBOutlet weak var latestVersionButton: NSButton!
    
    var progressWindow: NSWindowController?
    
    // MARK: View Life-cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        let defaultsController = NSUserDefaultsController.sharedUserDefaultsController()
       
        defaultsController.addObserver(self, forKeyPath: "values.autoStartup", options: NSKeyValueObservingOptions.New, context: nil)
        defaultsController.addObserver(self, forKeyPath: "values.autoUpdate", options: NSKeyValueObservingOptions.New, context: nil)
        defaultsController.addObserver(self, forKeyPath: "values.databasePath", options: NSKeyValueObservingOptions.New, context: nil)
        defaultsController.addObserver(self, forKeyPath: "values.logPath", options: NSKeyValueObservingOptions.New, context: nil)
        defaultsController.addObserver(self, forKeyPath: "values.mongodbVersion", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    override func viewDidDisappear() {
        let defaultsController = NSUserDefaultsController.sharedUserDefaultsController()
        
        defaultsController.removeObserver(self, forKeyPath: "values.autoStartup")
        defaultsController.removeObserver(self, forKeyPath: "values.autoUpdate")
        defaultsController.removeObserver(self, forKeyPath: "values.databasePath")
        defaultsController.removeObserver(self, forKeyPath: "values.logPath")
        defaultsController.removeObserver(self, forKeyPath: "values.mongodbVersion")
    }
    
    // MARK: KVO Methods
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "values.autoStartup" {
            if MongoDB.sharedServer.enabledOnStartup() {
                MongoDB.sharedServer.runOnStartup(false)
            }
            else {
                MongoDB.sharedServer.runOnStartup(true)
            }
        }
        else if keyPath == "values.autoUpdate" {
            if MongoDB.sharedServer.enabledUpdates() {
                MongoDB.sharedServer.scheduleUpdates(false)
            }
            else {
                MongoDB.sharedServer.scheduleUpdates(true)
            }
        }
        else if keyPath == "values.databasePath" || keyPath == "values.logPath" {
            MongoDB.sharedServer.restartServer()
        }
        else if keyPath == "values.mongodbVersion" {
            if let version = MongoDB.sharedServer.preferenceForKey("mongodbVersion") {
                self.enableVersionChange(version)
            }
        }
    }
    
    // MARK: UI Actions
    
    @IBAction func changeDataDirectory(sender: AnyObject) {
        self.chooseDirectory(forKey: "databasePath")
    }
    
    @IBAction func defaultDataDirectory(sender: AnyObject) {
        
        if let dataDir = MongoDB.sharedServer.defaultDatabaseDirectory() {
            MongoDB.sharedServer.setPreference(dataDir, forKey: "databasePath")
        }
    }
    
    @IBAction func changeLogDirectory(sender: AnyObject) {
        self.chooseDirectory(forKey: "logPath")
    }
    
    @IBAction func defaultLogDirectory(sender: AnyObject) {
        
        if let logDir = MongoDB.sharedServer.defaultLogDirectory() {
            MongoDB.sharedServer.setPreference(logDir, forKey: "logPath")
        }
    }
    
    @IBAction func changeVersion(sender: AnyObject) {
        let selectedVersion = MongoDB.sharedServer.preferenceForKey("mongodbVersion")
        
        if MongoDB.sharedServer.hasVersionAvailable(selectedVersion!) {
            MongoDB.sharedServer.restartServer()
            self.enableVersionChange(selectedVersion!)
        }
        else {
            var downloadAlert = NSAlert()
            downloadAlert.addButtonWithTitle("Download")
            downloadAlert.addButtonWithTitle("Cancel")
            downloadAlert.messageText = "Download MongoDB version \(selectedVersion!)?"
            downloadAlert.informativeText = "Version \(selectedVersion!) has not been downloaded yet. Do you want to download it now?"
            downloadAlert.alertStyle = NSAlertStyle.InformationalAlertStyle
            
            downloadAlert.beginSheetModalForWindow(self.view.window!, completionHandler: { (response) -> Void in
                
                if response == NSAlertFirstButtonReturn {
                    self.downloadVersion(selectedVersion!)
                } else if response == NSAlertSecondButtonReturn {
                    let currentVersion = MongoDB.sharedServer.currentVersion()

                    MongoDB.sharedServer.setPreference(currentVersion!, forKey: "mongodbVersion")
                    self.enableVersionChange(MongoDB.sharedServer.currentVersion()!)
                }
            })
        }
    }
    
    @IBAction func latestVersion(sender: AnyObject) {
        let latestVersion = MongoDB.sharedServer.latestVersion()
        MongoDB.sharedServer.setPreference(latestVersion, forKey: "mongodbVersion")
    }
    
    // MARK: DownloadDelegate Methods
    
    func urlForDownload() -> NSURL {
        return self.urlForVersion(MongoDB.sharedServer.preferenceForKey("mongodbVersion")!)
    }
    
    func messageForDownload() -> String {
        let version = MongoDB.sharedServer.preferenceForKey("mongodbVersion")!
        return "Downloading MongoDB version \(version)"
    }
    
    func downloadWasCancelled() {
        self.closeModal(self.progressWindow!.window!, withResponseCode: NSModalResponseCancel)
    }
    
    func downloadDidFinishSuccessfully(downloadedFile: NSURL) {
        
        let version = MongoDB.sharedServer.preferenceForKey("mongodbVersion")!
        
        let manager = NSFileManager.defaultManager()
        let bundlePath = NSBundle.mainBundle().bundlePath
        let path = bundlePath.stringByAppendingPathComponent("Contents/MongoDB/\(version)")
        
        manager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil)
        
        let (output, error) = NSTask.executeSyncTask("/usr/bin/tar", withArguments: ["xvjf", downloadedFile.path!, "-C", path, "--strip-components=1"])
        
        self.closeModal(self.progressWindow!.window!, withResponseCode: NSModalResponseOK)
    }
    
    func downloadDidFailWithError(error: NSError?) {
        
        var errorAlert = NSAlert()
        errorAlert.addButtonWithTitle("Okay")
        errorAlert.messageText = "Error downloading MongoDB version!"
        errorAlert.informativeText = error!.localizedDescription
        errorAlert.alertStyle = NSAlertStyle.WarningAlertStyle
        
        errorAlert.beginSheetModalForWindow(self.view.window!, completionHandler: { (response) -> Void in
            
            let currentVersion = MongoDB.sharedServer.currentVersion()
            
            MongoDB.sharedServer.setPreference(currentVersion!, forKey: "mongodbVersion")
            
            self.enableVersionChange(MongoDB.sharedServer.currentVersion()!)
        })
        
        self.closeModal(self.progressWindow!.window!, withResponseCode: NSModalResponseCancel)
    }
    
    // MARK: Private Methods
    
    private
    
    func downloadVersion(version: String) {
        
        self.progressWindow = self.storyboard?.instantiateControllerWithIdentifier("MongoProgressWindow") as? NSWindowController
        let downloadViewController = self.progressWindow!.contentViewController! as DownloadViewController
        
        downloadViewController.downloadDelegate = self

        self.view.window!.beginSheet(self.progressWindow!.window!, completionHandler: { (response) -> Void in

            if response == NSModalResponseCancel {
                let currentVersion = MongoDB.sharedServer.currentVersion()
                
                MongoDB.sharedServer.setPreference(currentVersion!, forKey: "mongodbVersion")
                
                self.enableVersionChange(MongoDB.sharedServer.currentVersion()!)
            }
            else if response == NSModalResponseOK {
                
                MongoDB.sharedServer.setPreference(version, forKey: "mongodbVersion")
                MongoDB.sharedServer.restartServer()
            }
        })
    }
    
    func enableVersionChange(version: String) {
        
        if let currentVersion = MongoDB.sharedServer.currentVersion() {
            if currentVersion != version {
                self.changeVersionButton.enabled = true
                self.latestVersionButton.enabled = true
            }
            else {
                self.changeVersionButton.enabled = false
                self.latestVersionButton.enabled = false
            }
        }
    }
    
    func chooseDirectory(forKey key: String!) {
        
        var panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        
        panel.beginWithCompletionHandler( { (result: Int) in
            if result == NSFileHandlingPanelOKButton {
                let url = panel.URLs[0] as NSURL
                MongoDB.sharedServer.setPreference(url.path!, forKey: key)
            }
        })
    }
    
    func closeModal(modal: NSWindow, withResponseCode responseCode: NSModalResponse) {
        self.view.window!.endSheet(modal, returnCode: responseCode)
    }
    
    func urlForVersion(version: String) -> NSURL {
        return NSURL(string: "http://downloads.mongodb.org/osx/mongodb-osx-x86_64-\(version).tgz")!
    }
}
