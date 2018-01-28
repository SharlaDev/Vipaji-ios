//
//  SelectVideoViewController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 9/24/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit
import AVFoundation

class SelectVideoViewController: UIViewController {
    @IBOutlet weak var CameraView: UIView!
    @IBOutlet weak var LibraryView: UIView!
    @IBOutlet weak var LibraryViewTopConstraint: NSLayoutConstraint!
    
    var captureDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var containerView: UIView!
    
    private var ButtonFlash: UIButton?
    private var ButtonRotateCamera: UIButton?
    private var ButtonToggleFullscreen: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        
        // Setup Camera Capture
        captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
        } catch {
            print(error)
        }
        
        // Setup containerView
        let window = UIApplication.shared.keyWindow!
        containerView = UIView(frame: CGRect(x: CameraView.bounds.origin.x, y: 64, width: UIScreen.main.bounds.width, height: CameraView.bounds.height))
        containerView.tag = 99
        //containerView.frame = CameraView.bounds
        containerView.clipsToBounds = true
        window.addSubview(containerView)
        
        // Configure and display camera capture
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        //videoPreviewLayer?.connection.videoOrientation = .landscapeLeft //todo: figure this out
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = containerView.bounds
        containerView.layer.insertSublayer(videoPreviewLayer!, at: 0) //(videoPreviewLayer!)
        
        captureSession?.startRunning()
        
        // Style nav bar
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 20.0)!, NSAttributedStringKey.foregroundColor: UIColor.white]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        containerView.frame = CGRect(x: CameraView.bounds.origin.x, y: 64, width: UIScreen.main.bounds.width, height: CameraView.bounds.height)
        
        addControls(insideView: containerView)
    }
    
    @IBAction func ToggleFlash(_ sender: UIButton) {
        if let device = captureDevice {
            do {
                if (device.hasTorch)
                {
                    try device.lockForConfiguration()
                    if device.torchMode == .off {
                        device.torchMode = .on
                        device.flashMode = .on
                    } else {
                        device.torchMode = .off
                        device.flashMode = .off
                    }
                    device.unlockForConfiguration()
                }
            } catch  {
                print(error)
            }
        }
    }
    
    // Mark: - Fullscreen
    
    private var isFullscreen: Bool = false
    @IBAction func ToggleFullscreen(_ sender: UIButton) {
        let window = UIApplication.shared.keyWindow!
        
        if !isFullscreen {
            isFullscreen = true
            
            // Resize views
            containerView.frame = CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height)
            videoPreviewLayer?.frame = containerView.bounds
            
            addControls(insideView: containerView)
            
            // Allow rotation
            (UIApplication.shared.delegate as! AppDelegate).isRotationAllowed = true
            
        } else {
            isFullscreen = false
            
            // Resize views
            containerView.frame = CGRect(x: CameraView.bounds.origin.x, y: 64, width: UIScreen.main.bounds.width, height: CameraView.bounds.height)
            videoPreviewLayer?.frame = containerView.bounds
            
            addControls(insideView: containerView)
            
            // Disable rotation
            (UIApplication.shared.delegate as! AppDelegate).isRotationAllowed = false
            
        }
    }
    
    // Mark: - Switch Camera
    
    enum cameras {
        case front, back
    }
    
    private var currentCamera: cameras = .back
    @IBAction func ToggleCamera(_ sender: UIButton) {
        if currentCamera == .back {
            // Set current camera to front camera
            let videoDevices = AVCaptureDevice.devices(for: AVMediaType.video)
            
            for device in videoDevices{
                let device = device
                if device.position == AVCaptureDevice.Position.front {
                    captureDevice = device
                }
            }
            
            currentCamera = .front
        } else {
            // Set current camera to back camera
            captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
            
            currentCamera = .back
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
        } catch {
            print(error)
        }
        
        // Update current camera layer without animations
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        containerView.layer.addSublayer(videoPreviewLayer!)
        videoPreviewLayer?.frame = containerView.layer.bounds
        
        addControls(insideView: containerView)
        CATransaction.commit()
        
        captureSession?.startRunning()
    }
    
    // Mark: - Record
    
    @IBAction func ToggleRecording(_ sender: UIRecordButton) {
        let buttonWidth = sender.bounds.width - 2*sender.layer.borderWidth
        let startingWidth: CGFloat = 12.0
        let center = sender.bounds.width/2 - startingWidth/2
        let scale = buttonWidth/startingWidth
        
        let innerCircleView = UIView(frame: CGRect(origin: CGPoint(x: center, y: center), size: CGSize(width: startingWidth, height: startingWidth)))
        innerCircleView.backgroundColor = UIColor.blue
        innerCircleView.layer.cornerRadius = startingWidth/2
        sender.addSubview(innerCircleView)
        
        UIView.animate(withDuration: 15) {
            innerCircleView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    // Mark: - Video Library
    private var isLibraryShown: Bool = false
    @IBAction func ToggleShowLibrary(_ sender: UIButton) {
        if !isLibraryShown {
            UIView.animate(withDuration: 0.4, animations: {
                sender.frame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.width, height: 60)
                self.LibraryView.frame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y + 60, width: self.view.bounds.width, height: self.view.bounds.height - 60)
            }, completion: { (completed) in
                //sender.setTitle("Record With My Camera", for: .normal)
            })
            //UIView.animate(withDuration: 0.4) {
                //sender.transform = CGAffineTransform(translationX: 0, y: 60 - self.view.bounds.height)
                //sender.constraints.
                //sender.frame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.width, height: 60)
                //self.LibraryView.transform = CGAffineTransform(translationX: 0, y: 60 - self.view.bounds.height)
                //sender.frame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.width, height: 60)
                //self.LibraryView.frame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y + 60, width: self.view.bounds.width, height: self.view.bounds.height - 60)
                
                
                //sender.setTitle("Record With My Camera", for: .normal)
            //}
            
            // Disable camera view
            captureSession?.stopRunning()
            containerView.isHidden = true
        } else {
            UIView.animate(withDuration: 0.5) {
                //sender.setTitle("Record With My Camera", for: .normal)
                sender.transform = CGAffineTransform(translationX: 0, y: 60 - self.view.bounds.height)
                //sender.frame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.width, height: 60)
                self.LibraryView.transform = CGAffineTransform(translationX: 0, y: 60 - self.view.bounds.height)
                //self.LibraryView.frame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y + 60, width: self.view.bounds.width, height: self.view.bounds.height - 60)
                
                self.LibraryViewTopConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
            
            captureSession?.startRunning()
            containerView.isHidden = false
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if tabBarController?.selectedIndex == 2 {
            // Resize views
            //let window = UIApplication.shared.keyWindow!
            //let origin = window.frame.origin

            containerView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            videoPreviewLayer?.frame = containerView.bounds
            
            addControls(insideView: containerView)
            
            // Update camera orientation
            if size.width > size.height {
                videoPreviewLayer?.connection?.videoOrientation = .landscapeRight
            } else {
                videoPreviewLayer?.connection?.videoOrientation = .portrait
            }
        }
    }
    
    // Mark: - Camera UI
    func addControls(insideView view: UIView) {
        // Remove existing controls
        view.viewWithTag(1)?.removeFromSuperview()
        view.viewWithTag(2)?.removeFromSuperview()
        view.viewWithTag(3)?.removeFromSuperview()
        view.viewWithTag(4)?.removeFromSuperview()
        
        let buttonFlash = UIButton(frame: CGRect(x: 0, y: view.frame.height - 46, width: 42, height: 42))
        buttonFlash.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        buttonFlash.setImage(UIImage(named: "Flash"), for: .normal)
        buttonFlash.addTarget(self, action: #selector(ToggleFlash), for: .touchUpInside)
        buttonFlash.tag = 1
        
        let buttonResize = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 46, y: view.bounds.height - 46, width: 42, height: 42))
        buttonResize.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        buttonResize.setImage(UIImage(named: "Resize"), for: .normal)
        buttonResize.addTarget(self, action: #selector(ToggleFullscreen), for: .touchUpInside)
        buttonResize.tag = 2
 
        let buttonSwitchCamera = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 46, y: 12, width: 42, height: 42))
        buttonSwitchCamera.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        buttonSwitchCamera.setImage(UIImage(named: "Switch Camera"), for: .normal)
        buttonSwitchCamera.addTarget(self, action: #selector(ToggleCamera), for: .touchUpInside)
        buttonSwitchCamera.tag = 3
        
        view.addSubview(buttonFlash)
        view.addSubview(buttonResize)
        view.addSubview(buttonSwitchCamera)
        
        if isFullscreen {
            let buttonRecord = UIRecordButton(frame: CGRect(x: view.bounds.width/2 - 32, y: view.frame.height - 68, width: 64, height: 64))
            buttonRecord.tag = 4
            view.addSubview(buttonRecord)
        } else {
            view.viewWithTag(4)?.removeFromSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let window = UIApplication.shared.keyWindow!
        window.addSubview(containerView)
        captureSession?.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        captureSession?.stopRunning()
        containerView.removeFromSuperview()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
