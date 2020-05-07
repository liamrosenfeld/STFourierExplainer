//
//  Array+Chunk.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/5/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import Foundation

public extension Array {
    /// Divides an array into chunks of size `size`
    ///
    /// If `self.count` not evenly divisible by `size`,
    /// the last chunk will be smaller
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
    
    /// Divides an array into chunks of size `size` but
    /// moving by `hop`
    ///
    /// If `self.count` not evenly divisible by `size`,
    /// the last chunk will be smaller
    func chunked(into size: Int, hop: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: hop).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

public extension Array where Element == Float {
    func pad(to size: Int) -> [Element] {
        if self.count == size {
            return self
        } else {
            let pad = [Float](repeating: 0, count: size - self.count)
            return self + pad
        }
    }
}
