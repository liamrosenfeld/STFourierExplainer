//
//  Array+Trim.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/5/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import Accelerate

public extension Array where Element == Array<Float> {
    
    // there must be a faster way but it works for now
    var zerosTrimmed: Self {
        var highestNonZero = self[0].count
        
        for set in self {
            for (index, item) in set.enumerated().reversed() {
                if item > 0.000001 {
                    if index < highestNonZero {
                        highestNonZero = index
                    }
                    break
                }
            }
        }
        
        highestNonZero += 25 // a bit of tolerance
        return self.map { Array<Float>($0[0..<highestNonZero]) }
    }
}
