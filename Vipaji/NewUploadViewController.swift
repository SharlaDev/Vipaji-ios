//
//  NewUploadViewController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 11/3/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit
import AVFoundation

class NewUploadViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var PlayerView: UIView!
    @IBOutlet weak var DescriptionTextView: UITextView!
    
    public var videoURL: URL!
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var initialViewHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show/Hide Keyboard Listeners
        NotificationCenter.default.addObserver(self, selector: #selector(NewUploadViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewUploadViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Configure Description TextView
        DescriptionTextView.delegate = self
        
        // Compress video and show
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!)
        let outputURL = documentsPath.appendingPathComponent("tmp\(NSUUID().uuidString).mp4")
        DispatchQueue.global(qos: .background).async {
            PostManager.compressFile(urlToCompress: self.videoURL, outputURL: outputURL!) { (url) in
                self.videoURL = url
                
                DispatchQueue.main.async {
                    // Create player and player layer
                    self.player = AVPlayer(url: url)
                    self.playerLayer = AVPlayerLayer(player: self.player)
                    self.playerLayer!.frame = self.PlayerView.bounds
                    self.PlayerView.layer.addSublayer(self.playerLayer!)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        initialViewHeight = self.view.frame.height
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initialViewHeight = self.view.frame.height
    }
    
    // MARK: - Upload
    
    @IBAction func UploadPost(_ sender: UIButton) {
        if videoURL != nil {
            PostManager.uploadPost(videoURL: videoURL, description: DescriptionTextView.text)
        }
    }
    
    // MARK: - Description TextView
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write a short description of your awesome talent..." {
            textView.text = ""
            textView.textColor = .white
        }
    }
    
    // Dismiss Keyboard
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    // Mark: - Show/Hide Keyboard
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            
            print(self.view.frame.origin.y)
            self.view.frame.origin.y = 49 - keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
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
