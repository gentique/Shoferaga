//
//  Dictionary+Merge.swift
//  Shoferaga
//
//  Created by Gentian Barileva on 5/20/18.
//  Copyright © 2018 Gentian Barileva. All rights reserved.
//
extension Dictionary {
    /// Merge and return a new dictionary
    func merge(with: Dictionary<Key,Value>) -> Dictionary<Key,Value> {
        var copy = self
        for (k, v) in with {
            // If a key is already present it will be overritten
            copy[k] = v
        }
        return copy
    }
    
    /// Merge in-place
    mutating func append(with: Dictionary<Key,Value>) {
        for (k, v) in with {
            // If a key is already present it will be overritten
            self[k] = v
        }
    }
}
