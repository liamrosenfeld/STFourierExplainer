/*:
 # The Short Time Fast Fourier Transform
 
 Hello! I'm Liam Rosenfeld. I'm an 11th grader from Florida and this is my WWDC20 Swift Student Challenge submission.
 It is a Swift Playground that explains the audio application of the short time fourier transform.
 
 Last year I was lucky enough to earn a WWDC19 scholarship, with [a playground](https://github.com/liamrosenfeld/FourierArtist) that used a discrete fourier transform to draw a path using a series of orbiting epicycles.
 
 When I explained what my project did the most common question I received was "what is it good for?", to which I normally responded "well for this application? just looking cool." However, I continued doing research into that certain application of mathematics I found how central it is to audio applications.
 
 As a member of my high school band, and general music lover, that intrigued me and I went down the rabbit hole of research.
 
 Now without further ado, let's dig into this together.
 
 _(If you just want to use the final product, jump to the [last page](Everything))_

 
 ## A Brief Recap of the Fourier Transform
 
 Waves are like smoothies.
 
 Think of each component of a wave as a fruit. Each has their own certain frequency and amplitude. But when combined together, they become this indiscernible mush with each still maintaining their individual properties.
 
 What a fourier transform does is un-blend that smoothie.
 
 For a discrete fast fourier transform (DFFT) it takes in an array of signal and returns the individual magnitudes for each frequency.
 
 To prevent this from overlapping with my submission last year, I won't dig too much into the math. If you want an explanation there is [my playground from last year](https://github.com/liamrosenfeld/FourierArtist) which implements a DFFT transform in Swift and [this absolutely wonderful video](https://youtu.be/spUNpyF58BY) by 3Blue1Brown which digs into the vector calculus behind it.
 
 This playground uses Accelerate's implementation of the DFFT because the scale of the signal wold be too slow on an imperative implementation. I first wrote this using the old API and then discovered the Swift Enum wrapper and converted it over to that to increase readability. It was an absolute joy to use—if you know someone on the Accelerate team please give them a high five after social distancing is over.
 
 
 ## The Short Time Fast Fourier Transform (STFFT)
 
 A single DFFT works great when a signal never changes, but if audio never changed it would be quite boring.
 
 So, the STFFT gets around that by essentially breaking down the signal into chunks, applying a window to reduce noise, and then applying a DFFT to each
 
 ## Spectrograms
 
 Spectrograms are a representation of all the magnitudes of the component frequencies of a sound over time.
 
 The spectrogram that will be used throughout this playground will have time going from left to right and frequency going from bottom to top.
 
 Let's use a STFFT to generate a spectrogram!
 */

import Accelerate

extension vDSP.FFT where T == DSPSplitComplex {
    public convenience init?(ofSize size: Int) {
        // check if the size is a power of two
        let sizeFloat: Float = Float(size)
        let lg2 = logbf(sizeFloat)
        assert(remainderf(sizeFloat, powf(2.0, lg2)) == 0, "size \(size) must be a power of 2")

        // create
        let log2n = vDSP_Length(log2(sizeFloat))
        self.init(log2n: log2n, radix: .radix2, ofType: DSPSplitComplex.self)
    }
}

public class Fourier {
    
    // constants
    let windowType: vDSP.WindowSequence = .hanningDenormalized
    let overlapRatio: Int = 8
    
    // parameters
    let size: Int
    
    // generated
    let fftSetUp: vDSP.FFT<DSPSplitComplex>
    let window: [Float]
    
    init(size: Int) {
        self.size = size
        self.fftSetUp = vDSP.FFT(ofSize: size)!
        self.window = vDSP.window(
            ofType: Float.self,
            usingSequence: windowType,
            count: size,
            isHalfWindow: false
        )
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
    /// - Returns: the fft for the entirety of `inBuffer`, of length `size / 2`
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
}

// The chunk size must be a power of two in order for the "fast" in fast fourier transform to apply
// The vertical resolution is half the chunk size, but the greater the chunk size the lower the horizontal resolution
// I found 512 to be a good balance between the two for these samples”
let size = 512
let fourier = Fourier(size: size)

let signal = AudioInput.readFile(file: "lick").signal // can change to any file name in resources

// this still contains phase information foe the inverse, which we can get rid of by taking the magnitude of all the complex vectors
let complexMagsOverTime = fourier.stfft(on: signal)
var mags: [[Float]] = complexMagsOverTime.map { (complexMags: ComplexBuffer) in
    var mags = [Float](repeating: 0.0, count: size / 2)
    vDSP.squareMagnitudes(complexMags.split, result: &mags)
    return mags
}

// the zerosTrimmed zooms in on the actual content
mags = mags.zerosTrimmed.map {
    // these magnitudes are linear
    // which makes it hard to see very low or very high values
    // decibels to the rescue!
    let temp = vDSP.amplitudeToDecibels($0, zeroReference: 0.1)
    return temp
}

//: Run it to see the spectrogram displayed!

// MARK: - Display
import PlaygroundSupport
import SwiftUI

let view = SpectrogramView(Binding.constant(mags))
PlaygroundPage.current.setLiveView(
    view
        .frame(width: 750, height: 500, alignment: .top)
        .background(Color.black)
)


/*:
 Now that we've gotten magnitudes from the signal, lets try to get it back
 
 [Next](@next)
 */
