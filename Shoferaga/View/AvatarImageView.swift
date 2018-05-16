//
//  AvatarImageView.swift
//  Shoferaga
//
//  Created by Gentian Barileva on 5/17/18.
//  Copyright © 2018 Gentian Barileva. All rights reserved.
//

import UIKit

@IBDesignable

class AvatarImageView: UIImageView {

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
    
    func customizeView(){
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.darkGray.cgColor
        layer.cornerRadius = layer.bounds.size.height / 2
        layer.masksToBounds = true
    }

}
