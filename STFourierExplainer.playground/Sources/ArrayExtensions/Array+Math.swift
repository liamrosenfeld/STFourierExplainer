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

public extension AccelerateBuffer where Element == Float {
    
    // array and array
    static func .+ (lhs: Self, rhs: Self) -> [Float] {
        return vDSP.add(lhs, rhs)
    }
    
    static func .* (lhs: Self, rhs: Self) -> [Float] {
        return vDSP.multiply(lhs, rhs)
    }
    
    static func .* (lhs: ArraySlice<Float>, rhs: Self) -> [Float] {
        return vDSP.multiply(lhs, rhs)
    }
    
    // scalar and array
    static func / (lhs: Self, rhs: Float) -> [Float] {
        return vDSP.multiply(1.0 / rhs, lhs)
    }
    
}

public extension ArraySlice where Element == Float {
    
    static func .+ (lhs: Self, rhs: Array<Float>) -> [Float] {
        return vDSP.add(lhs, rhs)
    }
    
}
