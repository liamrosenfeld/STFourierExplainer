//
//  Array+Math.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/5/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import Foundation
import Accelerate

// there's not much I like about matlab... but wow are these convenient

infix operator .+ : AdditionPrecedence
infix operator .* : MultiplicationPrecedence

public extension Array where Element == Float {
    
    // array and array
    static func .+ (lhs: Self, rhs: Self) -> Self {
        return vDSP.add(lhs, rhs)
    }
    
    static func .* (lhs: Self, rhs: Self) -> Self {
        return vDSP.multiply(lhs, rhs)
    }
    
    // scalar and array
    static func / (lhs: Self, rhs: Float) -> Self {
        return vDSP.multiply(1.0 / rhs, lhs)
    }
    
}
