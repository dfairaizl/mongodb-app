//
//  DownloadViewController.swift
//  MongoDB
//
//  Created by Dan Fairaizl on 2/24/15.
//  Copyright (c) 2015 TwentyBelow, LLC. All rights reserved.
//

import Cocoa

protocol DownloadDelegate {
    func urlForDownload() -> NSURL
    func messageForDownload() -> String
    func downloadWasCancelled()
    func downloadDidFinishSuccessfully(downloadedFile: NSURL)
    func downloadDidFailWithError(error: NSError?)
}

class DownloadViewController: NSViewController, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    @IBOutlet weak var downloadingLabel: NSTextField!
    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    var downloadDelegate: DownloadDelegate?
    
    var downloadSession: NSURLSession?
    var downloadTask: NSURLSessionDownloadTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let configiration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.downloadSession = NSURLSession(configuration: configiration, delegate: self, delegateQueue: NSOperationQueue.currentQueue())
    }
    
    override func viewWillAppear() {
        self.downloadingLabel.stringValue = self.downloadDelegate!.messageForDownload()
    }
    
    override func viewDidAppear() {
        if let url = self.downloadDelegate?.urlForDownload() {
            let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60)
            //request.setValue("Basic ODg3YzYzMjE0YjQ1ODgyYjY0MWI1ZDRlN2E1NWY4NjBlMzA2YjJhNzp4LW9hdXRoLWJhc2lj", forHTTPHeaderField: "Authorization")
            
            self.downloadTask = self.downloadSession?.downloadTaskWithRequest(request)
            self.downloadTask?.resume()
            
            self.progressIndicator.startAnimation(self.downloadTask)
        }
    }
    
    // MARK: UI ACTIONS
    
    @IBAction func cancelDownload(sender: AnyObject) {
        
        self.downloadTask?.cancel()
        self.downloadSession?.invalidateAndCancel()
  
        self.downloadDelegate?.downloadWasCancelled()
    }
    
    // MARK: NSURLSessionDownloadDelegate Methods
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        self.progressIndicator.maxValue = Double(totalBytesExpectedToWrite)
        
        self.progressIndicator.doubleValue = Double(totalBytesWritten)
        let progress = Int((Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)) * 100)
        self.progressLabel.stringValue = "\(progress)%"
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        self.progressIndicator.stopAnimation(self.downloadTask)
        
        self.downloadSession?.finishTasksAndInvalidate()

        self.downloadDelegate?.downloadDidFinishSuccessfully(location)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        self.progressIndicator.stopAnimation(self.downloadTask)
        
        self.downloadSession?.invalidateAndCancel()
        
        // Check server response status codes for error checking
        
        self.downloadDelegate?.downloadDidFailWithError(nil)
    }
}
