//
//  NSObject+Extensions.swift
//  Swifty ATM
//
//  Created by Gentian Barileva on 4/16/18.
//  Copyright © 2018 Gentian Barileva. All rights reserved.
//

import UIKit

extension NSObject {

    // Type Level
    static var className: String {
        return String(describing: self)
    }
    
    static var segueName: String {
        return String(describing: self) + "Segue"
    }
}
