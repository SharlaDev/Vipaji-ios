//
//  Extensions.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 9/15/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension Date
{
    func toString(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

extension String {
    func toDate(withFormat format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        return calendar.date(from: components)!
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    
    func generated(fromAsset asset: AVURLAsset) {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 0, preferredTimescale: 60)
        
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            self.image = UIImage(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error: \(error.debugDescription)")
        }
    }
}

extension UIImage {
    func crop(to:CGSize) -> UIImage {
        guard let cgimage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        let contextSize: CGSize = contextImage.size
        
        //Set to square
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cropAspect: CGFloat = to.width / to.height
        
        var cropWidth: CGFloat = to.width
        var cropHeight: CGFloat = to.height
        
        if to.width > to.height { //Landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2
        } else if to.width < to.height { //Portrait
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            posX = (contextSize.width - cropWidth) / 2
        } else { //Square
            if contextSize.width >= contextSize.height { //Square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                posX = (contextSize.width - cropWidth) / 2
            }else{ //Square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                posY = (contextSize.height - cropHeight) / 2
            }
        }
        
        let rect: CGRect = CGRect(x : posX, y : posY, width : cropWidth, height : cropHeight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        cropped.draw(in: CGRect(x : 0, y : 0, width : to.width, height : to.height))
        
        return cropped
    }
    
    func imageWithInsets(insetDimen: CGFloat) -> UIImage {
        return imageWithInset(insets: UIEdgeInsets(top: insetDimen, left: insetDimen, bottom: insetDimen, right: insetDimen))
    }
    
    func imageWithInset(insets: UIEdgeInsets) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets!
    }
}

extension UILabel {
    // Pass value for any one of both parameters and see result
    func setLineSpacing(to lineSpacing: CGFloat = 0.0, heightMultiple: CGFloat = 0.0) {
        
        guard let labelText = self.text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = heightMultiple
        
        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        
        // Line spacing attribute
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        self.attributedText = attributedString
    }
}

extension UIButton {
    func setTitleWithOutAnimation(title: String?) {
        UIView.setAnimationsEnabled(false)
        
        setTitle(title, for: .normal)
        
        layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
    }
}

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        //self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

extension UIView {
    /// Add a background layer consisting of a predefined vertical blue gradient
    func addGradientBackground() {
        DispatchQueue.global(qos: .background).async {
            let lightBlue = UIColor(red: 0.4, green: 0.57, blue: 0.94, alpha: 1.0).cgColor
            let darkBlue = UIColor(red: 0.13, green: 0.28, blue: 0.94, alpha: 1.0).cgColor
            
            DispatchQueue.main.async {
                let gradientLayer = CAGradientLayer()
                gradientLayer.colors = [lightBlue, darkBlue]
                gradientLayer.frame = self.bounds
                
                self.layer.insertSublayer(gradientLayer, at: 0)
                self.layoutSubviews()
            }
        }
    }
}

extension UISwitch {
    func scale(x: CGFloat, y: CGFloat) {
        self.transform = CGAffineTransform(scaleX: x, y: y)
    }
}
