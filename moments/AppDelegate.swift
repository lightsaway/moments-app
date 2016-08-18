//
//  AppDelegate.swift
//  moments
//
//  Created by Anton Serhiienko on 8/6/16.
//  Copyright © 2016 Serhiienko. All rights reserved.
//

import Cocoa
import AVFoundation
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let shooter = Shooter.sharedInstance
    
    let events : [String : String] = [
        NSWorkspaceSessionDidBecomeActiveNotification : "_login",
        NSWorkspaceSessionDidResignActiveNotification : "_logout",
        NSWorkspaceWillSleepNotification : "_sleep",
        NSWorkspaceScreensDidWakeNotification : "_awake",
        NSWorkspaceWillPowerOffNotification: "_powerOff"
    ]
    
    func eventListener(aNotification : NSNotification) {
        let suffix = events[aNotification.name];
        if((suffix) != nil){
            NSLog("Got %@ event", suffix! as String)
            shooter.takeSelfie(suffix! as String)
        }
        else{
            NSLog("Got unknown event %@", aNotification.name)
        }
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self, selector: #selector(AppDelegate.eventListener(_:)), name: NSWorkspaceSessionDidBecomeActiveNotification, object: nil)
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self, selector: #selector(AppDelegate.eventListener(_:)), name: NSWorkspaceWillSleepNotification, object: nil)
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self, selector: #selector(AppDelegate.eventListener(_:)), name: NSWorkspaceScreensDidWakeNotification, object: nil)
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self, selector: #selector(AppDelegate.eventListener(_:)), name: NSWorkspaceWillPowerOffNotification, object: nil)
        shooter.takeSelfie("_startup")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }

}

