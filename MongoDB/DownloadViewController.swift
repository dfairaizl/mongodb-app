//
//  DownloadViewController.swift
//  MongoDB
//
//  Created by Dan Fairaizl on 2/24/15.
//  Copyright (c) 2015 TwentyBelow, LLC. All rights reserved.
//

import Cocoa

class DownloadViewController: NSViewController, NSURLDownloadDelegate {
    
    @IBOutlet weak var downloadingLabel: NSTextField!
    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    var preferencesViewController: PreferencesViewController?
    var version: String = ""
    
    var download: NSURLDownload?
    var response: NSURLResponse?
    var bytesReceived: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        self.downloadingLabel.stringValue = "Downloading MongoDB version \(self.version)"
    }
    
    override func viewDidAppear() {
        if let url = urlForVersion(self.version) {
            let request = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60.0)
            
            self.download = NSURLDownload(request: request, delegate: self)
            
            if self.download == nil {
                NSLog("Error starting download!")
            }
        }
    }
    
    // MARK: UI ACTIONS
    @IBAction func cancelDownload(sender: AnyObject) {
        
        self.download?.cancel()
     
        if let preferences = self.preferencesViewController {
            preferences.view.window!.endSheet(self.view.window!, returnCode: NSModalResponseCancel)
        }
    }
    
    // MARK: NSURLDownload Methods
    
    func download(download: NSURLDownload, decideDestinationWithSuggestedFilename filename: String) {
        
        let manager = NSFileManager.defaultManager()
        let urls = manager.URLsForDirectory(NSSearchPathDirectory.CachesDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        
        if urls.count > 0 {
            let url = urls.last as NSURL
            download.setDestination(url.path!.stringByAppendingPathComponent(filename), allowOverwrite: false)
        }
    }
    
    func downloadDidBegin(download: NSURLDownload) {
        self.progressIndicator.startAnimation(self.download)
    }
    
    func download(download: NSURLDownload, didReceiveResponse response: NSURLResponse) {
     
        self.bytesReceived = 0
        self.response = response
    }

    func download(download: NSURLDownload, didReceiveDataOfLength length: Int) {
        
        let expectedLength = self.response?.expectedContentLength
        self.bytesReceived = self.bytesReceived + length
        
        let complete = (Double(self.bytesReceived) / Double(expectedLength!))
        let percentComplete = Int((Double(self.bytesReceived) / Double(expectedLength!)) * 100)
     
        if percentComplete >= 100 {
            self.progressLabel.stringValue = "100%"
        }
        else {
            self.progressLabel.stringValue = "\(percentComplete)%"
        }
        
        self.progressIndicator.incrementBy(complete)
    }
    
    func downloadDidFinish(download: NSURLDownload) {
        self.progressIndicator.stopAnimation(self.download)
    }
    
    func download(download: NSURLDownload, didFailWithError error: NSError) {
        self.progressIndicator.stopAnimation(self.download)
    }
    
    // MARK: Private Methods
    
    private
    
    func urlForVersion(version: String) -> NSURL? {
        return NSURL(string: "http://downloads.mongodb.org/osx/mongodb-osx-x86_64-\(version).tgz")
    }
}
