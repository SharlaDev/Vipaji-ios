//
//  FullscreenPlayerView.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 11/29/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit

class FullscreenPlayerView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard let gradientLayer = self.layer as? CAGradientLayer else { return }
        gradientLayer.colors = [
            UIColor.blue.cgColor,
            UIColor.cyan.cgColor
        ]
    }
}
