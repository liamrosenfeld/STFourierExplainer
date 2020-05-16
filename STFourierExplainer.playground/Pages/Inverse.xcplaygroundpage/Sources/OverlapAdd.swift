//
//  OverlapAdd.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/13/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import Accelerate

public func overlapAdd(_ chunks: [[Float]], size: Int, hop: Int) -> [Float] {
    // calculate final size
    let finalLength = chunks.count * hop
    let overlapRatio = size / hop
    
    // combine all the chunks, adding parts that overlap
    var signal: [Float] = [Float](repeating: 0, count: finalLength + size)
    for (index, start) in stride(from: 0, to: finalLength - 1, by: hop).enumerated() {
        let range = start..<(start+size)
        let added = signal[range] .+ chunks[index]
        signal.replaceSubrange(range, with: added)
    }
    
    // scale it down to go back to original magnitude
    signal = signal / Float(overlapRatio / 2)
    
    return signal
}
