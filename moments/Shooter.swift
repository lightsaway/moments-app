//
//  Shooter.swift
//  moments
//
//  Created by Anton Serhiienko on 8/6/16.
//  Copyright © 2016 Serhiienko. All rights reserved.
//

import Foundation
import AVFoundation

class Shooter {
    static let sharedInstance = Shooter()
    
    let FOLDERNAME = "moments"
    
    let cameraQueue = dispatch_queue_create("com.lightsaway.Moments.Queue", DISPATCH_QUEUE_SERIAL);
    let captureSession = AVCaptureSession();
    var stillImageOutput : AVCaptureStillImageOutput?
    private var cameraTurnedOn = false
    
    private init(){
        setupCamera()
        createSubFolder(FOLDERNAME, location: .DocumentDirectory)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Shooter.cameraListener(_:) ), name: AVCaptureSessionDidStartRunningNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Shooter.cameraListener(_:) ), name: AVCaptureSessionDidStopRunningNotification, object: nil)
    }
    
    
    @objc func cameraListener(aNotification : NSNotification){
        if aNotification.name == AVCaptureSessionDidStartRunningNotification{
            NSLog("Camera is ON")
            cameraTurnedOn = true
        }else if aNotification.name == AVCaptureSessionDidStopRunningNotification{
            NSLog("Camera is OFF")
            cameraTurnedOn = false        }
    }
    
    
    
    private func setupCamera(){
        NSLog("SETTING UP CAMERA")
        self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let camera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        NSLog("Current camera is %@", camera.localizedName)
        
        do{
            let input = try AVCaptureDeviceInput(device: camera)
            if ( captureSession.canAddInput(input)){
                
                captureSession.addInput(input)
                
                stillImageOutput = AVCaptureStillImageOutput()
                stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
                
                if (captureSession.canAddOutput(stillImageOutput)){
                    captureSession.addOutput(stillImageOutput)
                }
                
            }
            
        } catch let error as NSError {
            print(error)
        }
    }
    
    
    func createSubFolder(subDirName: String, location: NSSearchPathDirectory ) -> Bool {
        guard let locationUrl = NSFileManager().URLsForDirectory(location, inDomains: .UserDomainMask).first else { return false }
        do {
            try NSFileManager().createDirectoryAtURL(locationUrl.URLByAppendingPathComponent(subDirName), withIntermediateDirectories: false, attributes: nil)
            return true
        } catch let error as NSError {
            NSLog("ERROR %@",error.description)
            return false
        }
    }
    
    
    func takeSelfie(suffix : String){
        NSLog("STARTING VIDEO STREAM")
        captureSession.startRunning();
        
        //STUPID WORKAROUND SINCE CAMERA INPUT HAS SOME LATENCY
        //NEED TO FIND BETTER WAY USING EVENT SYSTEM and possible dispatch_async block
        
        sleep(2)
        
        NSLog("STARTED VIDEO STREAM")
        
        let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo)
        
        //IF THERE IS VIDEO CONNECTION
        if videoConnection != nil && (videoConnection?.active)! {
            
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                (sampleBuffer, error) in
                
                if sampleBuffer != nil {
                    NSLog("Got picture")
                    
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let date = String(NSDate().timeIntervalSince1970);
                    
                    let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
                    let fileURL = documentsURL.URLByAppendingPathComponent( self.FOLDERNAME + "/" + date + suffix + ".png")
                    print(fileURL)
                    let result =  Bool(imageData.writeToURL(fileURL, atomically: true))
                    NSLog("Result of storing photo = %@ , name of file = %@", result, fileURL)
                    
                    dispatch_async(self.cameraQueue) {
                        NSLog("STOPPING VIDEO STREAM")
                        self.captureSession.stopRunning()
                        NSLog("STOPPED VIDEO STREAM")
                    }
                }
            })
        }
    }
}