//
//  Udhetare.swift
//  Shoferaga
//
//  Created by Gentian Barileva on 5/19/18.
//  Copyright © 2018 Gentian Barileva. All rights reserved.
//

import Foundation

class Udhetare{
    private(set) public var name: String
    private(set) public var surname: String
    private(set) public var email: String
    private(set) public var phoneNumber: String
    private(set) public var money: Double
    private(set) public var worker: Bool
    private(set) public var lat: Double
    private(set) public var lon: Double
    
    init(name: String, surname: String, email: String, phoneNumber: String, money: Double, worker: Bool, lat: Double, lon: Double) {
        self.name = name
        self.surname = surname
        self.email = email
        self.phoneNumber = phoneNumber
        self.money = money
        self.worker = worker
        self.lat = lat
        self.lon = lon
    }
    func updateLocation(_ lat: Double, lon: Double){
        self.lat = lat
        self.lon = lon
    }
}

