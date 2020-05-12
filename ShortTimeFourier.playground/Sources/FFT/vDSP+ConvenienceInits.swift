//
//  vDSP+ConvenienceInits.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/12/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//


import Accelerate

public extension vDSP.FFT where T == DSPSplitComplex {
    convenience init?(ofSize size: Int) {
        // check if the size is a power of two
        let sizeFloat: Float = Float(size)
        let lg2 = logbf(sizeFloat)
        assert(remainderf(sizeFloat, powf(2.0, lg2)) == 0, "size \(size) must be a power of 2")

        // create
        let log2n = vDSP_Length(log2(sizeFloat))
        self.init(log2n: log2n, radix: .radix2, ofType: DSPSplitComplex.self)
    }
}

public extension vDSP {
    static func window(ofSize size: Int) -> [Float] {
        return vDSP.window(
            ofType: Float.self,
            usingSequence: .hanningDenormalized,
            count: size,
            isHalfWindow: false
        )
    }
}
