//
//  UdhetareSimpleList.swift
//  Shoferaga
//
//  Created by Gentian Barileva on 5/19/18.
//  Copyright © 2018 Gentian Barileva. All rights reserved.
//

import Foundation

class UdhetareSimpleList{
    private(set) public var Name = String()
    private(set) public var FIRKey = String()
    private(set) public var lat = Double()
    private(set) public var lon = Double()
    init(name :String, firKey: String, lat: Double, lon: Double) {
        self.Name = name
        self.FIRKey = firKey
        self.lat = lat
        self.lon = lon
    }
}
