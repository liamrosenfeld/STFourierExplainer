//
//  ComplexBuffer.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/5/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import Accelerate

/// DSPSplitComplex but it has the real and imag part bundled.
/// So it can be passed around different scopes without the arrays being deinit
public class ComplexBuffer {
    private var real: [Float]
    private var imag: [Float]
    
    public  var split: DSPSplitComplex
    
    public init(size: Int) {
        self.real = [Float](repeating: 0.0, count: size)
        self.imag = [Float](repeating: 0.0, count: size)
        
        // these properties of the same type, so it won't be left dangling
        let realPtr = UnsafeMutablePointer(mutating: real)
        let imagPtr = UnsafeMutablePointer(mutating: imag)
        self.split = DSPSplitComplex(realp: realPtr, imagp: imagPtr)
    }
    
}
