//
//  FullscreenView.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 11/30/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit

class FullscreenView: UIView {
    
    var videoLayer: CALayer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, contentLayer: CALayer) {
        super.init(frame: frame)
        
        // This allows us to make changes to layers without implicit animations
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        videoLayer = contentLayer
        layer.addSublayer(videoLayer)
        
        CATransaction.commit()
    }
    
    init(contentLayer: CALayer) {
        super.init(frame: CGRect.zero)
        
        // This allows us to make changes to layers without implicit animations
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        videoLayer = contentLayer
        layer.addSublayer(videoLayer)
        
        CATransaction.commit()
    }
    
    override func layoutSubviews() {
        // This allows us to make changes to layers without implicit animations
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        videoLayer.frame = self.bounds
        
        CATransaction.commit()
    }
}
