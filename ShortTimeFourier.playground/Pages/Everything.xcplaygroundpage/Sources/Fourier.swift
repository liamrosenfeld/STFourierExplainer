//
//  Fourier.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/5/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import Accelerate

/// A collection of Fast Fourier Functions built atop Apple's Accelerate framework
/// for optimum performance on any device.
///
/// Note that all functions expect a mono signal (i.e. numChannels == 1)
public class Fourier {
    
    // constants
    let windowType: vDSP.WindowSequence = .hanningDenormalized
    let overlapRatio: Int = 8
    
    // parameters
    let size: Int
    
    // generated
    let fftSetUp: vDSP.FFT<DSPSplitComplex>
    let window: [Float]
    let hop: Int
    
    /// creates an instance of Fourier
    /// - Parameter size: size between all functions (ftt: input size, ifft: output size, stfft: chunk size), must be a power fo 2
    init(size: Int) {
        // check if the size is a power of two
        let sizeFloat: Float = Float(size)
        let lg2 = logbf(sizeFloat)
        assert(remainderf(sizeFloat, powf(2.0, lg2)) == 0, "size \(size) must be a power of 2")
        
        // save size
        self.size = size
        self.hop = size / overlapRatio

        // create fft setup
        let log2n = vDSP_Length(log2(sizeFloat))
        self.fftSetUp = vDSP.FFT(log2n: log2n, radix: .radix2, ofType: DSPSplitComplex.self)!
        
        // create windows
        self.window = vDSP.window(ofType: Float.self, usingSequence: windowType, count: size, isHalfWindow: false)
    }
    
    /// short time fast fourier transform, uses OLA
    /// - Parameter inBuffer: Audio data in mono format
    /// - Returns: the fft for each chunk, each of length `size / 2`
    ///
    /// hop size is `size / overlapRatio`
    func stfftOLA(on inBuffer: [Float]) -> [ComplexBuffer] {
        // divide into chunks of size
        var chunks = inBuffer.chunked(into: size, hop: size / 8)
        chunks = chunks.map { $0.pad(to: size) }
        
        let freqs = chunks.map { chunk in
            return fft(buffer: chunk)
        }
        
        return freqs
    }
    
    /// inverse short time fast fourier transform, uses OLA
    /// - Parameter complexBuffer: Complex buffer from `stfftOLA`
    /// - Returns: the original signal, of length `size`
    func istfftOLA(on complexBuffer: [ComplexBuffer]) -> [Float] {
        let chunksAgain: [[Float]] = complexBuffer.map { ifft(complexBuffer: $0.split) }
        
        let finalLength = chunksAgain.count * hop
        var signal: [Float] = [Float](repeating: 0, count: finalLength + size)
        for (index, start) in stride(from: 0, to: finalLength - 1, by: hop).enumerated() {
            let range = start..<start+size
            let existingPart = signal[range]
            let newPart = chunksAgain[index]
            let added = Array(existingPart) .+ newPart
            signal.replaceSubrange(range, with: added)
        }
        
        // scale it down
        signal = signal / Float(overlapRatio / 2)
        
        return signal
    }
    
    /// short time fast fourier transform, does not use OLA
    /// - Parameter inBuffer: Audio data in mono format
    /// - Returns: the fft for each chunk, each of length `size / 2`
    func stfft(on inBuffer: [Float]) -> [ComplexBuffer] {
        // divide into chunks of size
        var chunks = inBuffer.chunked(into: size)
        chunks = chunks.map { $0.pad(to: size) }
        let freqs = chunks.map { chunk in
            return fft(buffer: chunk)
        }
        
        return freqs
    }

    /// fast fourier transform
    /// - Parameter inBuffer: Audio data in mono format
    /// - Returns: the fft for the entirity of `inBuffer`, of length `size / 2`
    func fft(buffer inBuffer: [Float]) -> ComplexBuffer {
        // sizes
        let outSize = size / 2
    
        // create in and out buffers
        let windowedBuffer = ComplexBuffer(size: outSize)
        let outBuffer = ComplexBuffer(size: outSize)
        
        // apply the window
        let windowedInterleaved = inBuffer .* window
        
        // convert the interleaved vector into a complex split vector.
        // (moves the even indexed samples into realp and the odd indexed samples into imagp)
        windowedInterleaved.withUnsafeBytes {
            vDSP.convert(interleavedComplexVector: [DSPComplex]($0.bindMemory(to: DSPComplex.self)),
                         toSplitComplexVector: &windowedBuffer.split)
        }

        // Perform a forward FFT
        fftSetUp.forward(input: windowedBuffer.split, output: &outBuffer.split)

        
        return outBuffer
    }


    func ifft(complexBuffer: DSPSplitComplex) -> [Float] {
        // do inverse
        let inSize = size / 2
        let outputBuffer = ComplexBuffer(size: inSize)
        fftSetUp.inverse(input: complexBuffer, output: &outputBuffer.split)
        
        // get floats from complex
        let scale = 1 / Float(size * 2)
        return [Float](fromSplitComplex: outputBuffer.split, scale: scale, count: size)
    }
    
    /// A convenience function that converts a split complex vector to its linear magnitudes (squared).
    static func magnitudes(for complexBuffer: DSPSplitComplex, size: Int) -> [Float] {
        var magnitudes = [Float](repeating: 0.0, count: size)
        vDSP.squareMagnitudes(complexBuffer, result: &magnitudes)
        return magnitudes
    }
}
