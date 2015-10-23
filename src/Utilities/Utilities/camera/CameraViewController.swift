//
//  CameraViewController.swift
//  Camera
//
//  Created by Carmelo I. Uria on 10/26/14.
//  Copyright (c) 2014 Carmelo Uria Corporation. All rights reserved.
//

import UIKit
import AVFoundation

public class CameraViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate
{
    var captureSession:AVCaptureSession?
    var audioPlayer:AVAudioPlayer!
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?

    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let isCameraReady:Bool = self.setupCamera()
        
        if (isCameraReady == true)
        {
            debugPrint("camera is ready")
            self.loadBeepSound()
        }
        else
        {
            debugPrint("camera is not available")
        }
        
    }

    public override func canPerformUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject) -> Bool
    {
        return true
    }
    public override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:  - IBAction methods
    
    @IBAction public func prepareUnwindSegue(sender: UIStoryboardSegue)
    {
        debugPrint("\(__FUNCTION__)")
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func popViewController(sender: AnyObject)
    {
        debugPrint("\(__FUNCTION__)")
        self.navigationController?.popViewControllerAnimated(true)
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    public override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue?
    {
        return nil
    }
    
    // MARK:  - private methods

    private func setupCamera() -> Bool
    {
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        var input: AVCaptureDeviceInput?
        
        do
        {
            try input = AVCaptureDeviceInput(device: captureDevice)
        }
        catch
        {
            print("\(error)")
        }

        if (input == nil)
        {
            return false;
        }
        
        // Initialize the captureSession object.
        self.captureSession = AVCaptureSession()
        
        // Set the input device on the capture session.
        self.captureSession?.addInput(input)
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput:AVCaptureMetadataOutput = AVCaptureMetadataOutput()
        self.captureSession?.addOutput(captureMetadataOutput)

        // Create a new serial dispatch queue.
        var dispatchQueue:dispatch_queue_t
        dispatchQueue = dispatch_queue_create("myQueue", nil)
        
        
        let metadataObjects:[AnyObject] = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeDataMatrixCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeFace]

        captureMetadataOutput.metadataObjectTypes = metadataObjects
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatchQueue)
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.videoPreviewLayer?.frame = self.view.layer.bounds
        self.view.layer.addSublayer(self.videoPreviewLayer!)
        
        // Start video capture.
        self.captureSession?.startRunning()
        
        return true

    }
    
    private func loadBeepSound()
    {
        let beepPath:String = NSBundle.mainBundle().pathForResource("beep", ofType: "mp3")!
        let beepURL:NSURL = NSURL(fileURLWithPath: beepPath)
        
        // Initialize the audio player object using the NSURL object previously set.
        do
        {
            try self.audioPlayer =  AVAudioPlayer(contentsOfURL: beepURL)
            self.audioPlayer.prepareToPlay()
        }
        catch
        {
            print("Could not play beep file.")
            print("\(__FUNCTION__)::  error:  \(error)")
        }

    }

    //MARK: - AVCaptureMetadataOutputObjectsDelegate method implementation
    
    public func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!,
        fromConnection connection: AVCaptureConnection!)
    {

        debugPrint("\(__FUNCTION__)")
        
        for metadataObject in metadataObjects
        {
            let x:AVMetadataObject = metadataObject as! AVMetadataObject
            debugPrint( "metadataObject: \(x)")
        }
        
        self.audioPlayer.play()
    }
}

