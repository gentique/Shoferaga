//
//  MainLogInButtonsView.swift
//  Shoferaga
//
//  Created by Gentian Barileva on 5/16/18.
//  Copyright © 2018 Gentian Barileva. All rights reserved.
//

import UIKit

@IBDesignable

class MainLogInButtonsView: UIButton {

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
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
    }

}
