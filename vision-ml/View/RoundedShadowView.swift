//
//  RoundedShadowView.swift
//  vision-ml
//
//  Created by Cody Lee on 10/6/17.
//  Copyright © 2017 CJLeeApps. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedShadowView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func prepareForInterfaceBuilder() {
        customizeView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customizeView()
    }
    
    func customizeView() {
        clipsToBounds = true
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = (self.frame.size.height / 2)
    }

}
