/*:
 # The Short Time Fast Fourier Transform
 
 Hello! I'm Liam Rosenfeld. I'm an 11th grader from Florida and this is my WWDC20 Swift Student Challenge submission.
 It is a Swift Playground that explains the audio application of the short time fourier transform.
 Last year I was lucky enough to earn a WWDC19 scholarship, with [a playground](https://github.com/liamrosenfeld/FourierArtist) that used a discrete fourier transform to draw a path using a series of orbiting epicycles.
 When explaining my project, the most common question I received was "what is it good for?". I would respond "well for this application? just looking cool." However, I continued learning about that area of mathematics and found how fourier transforms apply to digital signal processing.
 As a member of my high school band, and general music lover, that intrigued me and I went down the rabbit hole of research.
 
 Now without further ado, let's dig into this together.
 
 _(If you want to skip the explanation, jump to the [last page](Everything))_

 
 ## A Brief Recap of the Fourier Transform
 
 Waves are like smoothies.
 
 Think of each component of a wave as fruit. Each has their own certain frequency and amplitude. But when combined together, they become an indiscernible mush with each fruit contributing their individual properties.
 Fourier transforms allow you to un-blend that smoothie.
 
 A discrete fast fourier transform (DFFT) takes in a signal in the form of an array of samples and returns the individual magnitudes for each frequency.
 
 Last year [my playground](https://github.com/liamrosenfeld/FourierArtist) related the equation of a DFFT to code and provided a visual proof. If you want to explore the vector calculus behind this all, check out [this absolutely wonderful video](https://youtu.be/spUNpyF58BY) by 3Blue1Brown.
 
 This playground uses Accelerate's implementation of the DFFT because we will be working with relatively large signals that would be too slow on an imperative implementation. I first wrote this using the old API and then discovered the Swift Enum wrapper and converted it over to increase readability. It was an absolute joy to use—if you know someone on the Accelerate team, please give them a high five after social distancing is over.
 
 
 ## The Short Time Fast Fourier Transform (STFFT)
 
 A single DFFT works great when a signal never changes, but if audio never changed it would be quite boring.
 So, the STFFT gets around that by essentially breaking down the signal into chunks, applying a window to reduce noise, and then applying a DFFT to each chunk.
 
 ## Spectrograms
 
 Spectrograms are a representation of all the magnitudes of the component frequencies of a sound over time.
 The spectrogram that will be used throughout this playground will have time on the x-axis and frequency (in hertz) on the y-axis.
 The code that draws the spectrogram using core graphics can be found in `Spectrogram/NSSpectrogramView.swift` in the global Sources folder.
 
 Let's use a STFFT to generate a spectrogram!
 */

import Accelerate

// The chunk size must be a power of two in order for the "fast" in fast fourier transform to apply
// The vertical resolution is half the chunk size, but the greater the chunk size the lower the horizontal resolution
// I found 512 to be a good balance between the two for these samples
let size = 512

// This grabs the amplitudes of the waveform stored in a wav file
// You can change this to any file in resources (or add your own)
// Currently it's The Lick... mmmmm jazz
// https://youtu.be/krDxhnaKD7Q
let file = AudioInput.readFile(file: "lick")
let signal = file.signal

//: The STFFT is a bunch of FFTs at it's core, so lets make an Accelerate powered FFT function
//: What it does is explained in the comments

let fft = vDSP.FFT(ofSize: size)!
let window = vDSP.window(ofSize: size)

func fft(buffer inBuffer: [Float]) -> ComplexBuffer {
    // The resolution of the output is half of the input size
    // This is why it's it's good to have a decent, but not too large, input size
    // The resolution does not have a 1:1 ratio for frequency, so similar frequencies are essentially combined into a "band"
    let outSize = size / 2

    // These are empty buffers where we will store complex numbers along the way
    // ComplexBuffer stores the real and imaginary arrays in the same place as the DSPComplex so I can worry less about keeping track of memory
    let windowedBuffer = ComplexBuffer(size: outSize)
    let outBuffer = ComplexBuffer(size: outSize)
    
    
    // Windowing prevents spectral leakage
    // Spectral leakage is what happens when the chunk taken does not perfectly match the period of the waveform
    // A FFT effectively assumes that the end of the input leads directly back into the start, causing an infinite loop of a signal
    // However, if there is a jump between the end and the start the FFT can pick up on false frequencies
    // Windowing reduces the amplitude of the wave as it approaches the sides of the chunk, so both ends naturally end at 0
    // This playground uses the Hann window, which in my testing, I found to be a good balance between not being overly aggressive and still ending at 0
    // This is beneficial, but as we’ll see in the next page, it can be problematic when regenerating the signal
    //
    // .* is a custom operator implemented in Array+Math.swift that uses Accelerate behind the scenes
    // It's shamelessly copied from Matlab. I have an interesting relationship with Matlab, but those element-wise operators are convenient.
    let windowedInterleaved = inBuffer .* window
    
    // Convert the interleaved vector into a complex split vector
    // (moves the even indexes into realp and the odd indexes into imagp)
    windowedInterleaved.withUnsafeBytes {
        vDSP.convert(interleavedComplexVector: [DSPComplex]($0.bindMemory(to: DSPComplex.self)),
                     toSplitComplexVector: &windowedBuffer.split)
    }

    // Perform a forward FFT
    fft.forward(input: windowedBuffer.split, output: &outBuffer.split)

    return outBuffer
}

//: Now that we have that built, let's use it in a STFFT

// Divide the signal into chunks of size
var chunks = signal.chunked(into: size)

// Pad the last chunk with zeros so it can still be analyzed
chunks[chunks.count - 1] = chunks.last!.pad(to: size)

// Apply the FFT to each chunk
let complexMagsOverTime = chunks.map { chunk in
    return fft(buffer: chunk)
}

//: Boom. That's our STFFT.
//: Now all that's left us calculating the magnitudes to display on the spectrograph.

// complexMagsOverTime contains phase information for the inverse (angle that the complex vector is at)
// which we can get rid of by taking the magnitude of all the complex vectors
var mags: [[Float]] = complexMagsOverTime.map { (complexMags: ComplexBuffer) in
    var mags = [Float](repeating: 0.0, count: size / 2)
    vDSP.squareMagnitudes(complexMags.split, result: &mags)
    return mags
}

// The zerosTrimmed zooms in on the actual content
mags = mags.zerosTrimmed.map {
    // These magnitudes are linear
    // which makes it hard to see very low or very high values
    // Decibels are logarithmic so they make both smaller and larger values easier to see
    let temp = vDSP.amplitudeToDecibels($0, zeroReference: 0.1)
    return temp
}

/*:
 Run it to see the spectrogram displayed!
 
 Now that we've gotten magnitudes from the signal, let's try to get it back

 [Next](@next)
 
*/


// MARK: - Display
import PlaygroundSupport
PlaygroundPage.current.setLiveView(
    ForwardView(
        mags,
        sampleRate: file.format.sampleRate,
        origResolution: size / 2
    )
)



