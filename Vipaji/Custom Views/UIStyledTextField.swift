//
//  UIPaddedTextField.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 10/27/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit

@IBDesignable
class UIStyledTextField: UITextField {
    
    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let textRect = super.leftViewRect(forBounds: bounds)
        //textRect.origin.x += padding
        return textRect
    }
    
    // Provides right padding for images
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let textRect = super.rightViewRect(forBounds: bounds)
        //textRect.origin.x -= padding
        return textRect
    }
    
    @IBInspectable var leadingImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var rtl: Bool = false {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var padding: CGFloat = 0
    
    func updateView() {
        let tmpPadding: CGFloat = 10.0 //workaround for padding variable, which for some reason remains at 0
        
        rightViewMode = UITextFieldViewMode.never
        rightView = nil
        leftViewMode = UITextFieldViewMode.never
        leftView = nil
        
        if let image = leadingImage {
            let containerWidth = self.bounds.height
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: containerWidth))
            
            let imageWidth = containerWidth - 2.0*tmpPadding
            let imageView = UIImageView(frame: CGRect(x: tmpPadding, y: tmpPadding, width: imageWidth, height: imageWidth))
            imageView.image = image
            imageView.contentMode = .scaleToFill
            
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = color
            
            containerView.addSubview(imageView)
            
            if rtl {
                rightViewMode = UITextFieldViewMode.always
                rightView = containerView
            } else {
                leftViewMode = UITextFieldViewMode.always
                leftView = containerView
            }
        }
        
        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: color])
    }
}
