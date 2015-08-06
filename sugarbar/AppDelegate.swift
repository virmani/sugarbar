//
//  AppDelegate.swift
//  sugarbar
//
//  Created by Ashish Virmani on 7/9/15.
//  Copyright (c) 2015 Ashish Virmani. All rights reserved.
//

import Cocoa
import SwiftyJSON
import SwiftHTTP

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var nighscoutDomain: NSTextField!
    
    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var bloodSugarFetcher: BloodSugarFetcher?
    var lastUpdated: NSTimeInterval = 0
    
    var timer = NSTimer()
    let TIME_INCREMENT: Double = 60
    let MAX_INTERVAL: Double = 600
    let NO_VALUE = "XX"
    
    override func awakeFromNib() {
        setupMenubar()
    }
    
    @IBAction func startTracking(sender: NSButton) {
        //TODO: Add domain validation
        bloodSugarFetcher = BloodSugarFetcher(domain: nighscoutDomain.stringValue)
        
        refreshMenuBarValue()
        timer = NSTimer.scheduledTimerWithTimeInterval(
            TIME_INCREMENT,
            target:self,
            selector: Selector("refreshMenuBarValue"),
            userInfo: nil,
            repeats: true)
        
        self.window!.orderOut(self)
    }
    
    func refreshMenuBarValue() {
        let currentTime = NSDate().timeIntervalSince1970
        
        if (currentTime - lastUpdated > MAX_INTERVAL) {
            //TODO: strikethrough current value
            self.statusBarItem.title = NO_VALUE
        }
        
        bloodSugarFetcher!.refreshBloodSugar({ (bs: String, direction: String) -> () in
            self.statusBarItem.title = bs + " " + direction
            self.lastUpdated = NSDate().timeIntervalSince1970
        })
    }

    func setWindowVisible(sender: AnyObject){
        self.window!.orderFrontRegardless()
    }
    
    func setupMenubar() {
        //Add statusBarItem
        statusBarItem = statusBar.statusItemWithLength(-1)
        statusBarItem.menu = menu
        statusBarItem.title = NO_VALUE
        
        var menuItem : NSMenuItem = NSMenuItem()
        //Add menuItem to menu
        menuItem.title = "Settings"
        menuItem.action = Selector("setWindowVisible:")
        menuItem.keyEquivalent = ","
        menu.addItem(menuItem)
        
        menuItem = NSMenuItem()
        menuItem.title = "Quit"
        menuItem.action = Selector("exit:")
        menuItem.keyEquivalent = "q"
        menu.addItem(menuItem)
    }
    
    func exit(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
    
}


