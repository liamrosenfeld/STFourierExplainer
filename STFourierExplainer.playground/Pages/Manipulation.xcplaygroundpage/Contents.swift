/*:
[Previous](@previous)

# Manipulating The Components

To return to the smoothie analogy, imagine if you made a large amount of mixed berry smoothie. However, someone that you were going to give it to doesn’t like blueberries. Un-blending the smoothie would allow you to remove those blueberries after the fact. That is effectively what we’re going to do to the ringing in this waveform.

## How?

[.......]

*/

//: Let's first do a STFFT without OLA for display and with OLA for manipulation

let file = AudioInput.readFile(file: "lickRinging")
let signal = file.signal

let size = 512
let fourier = Fourier(size: size)
let stfft = fourier.stfft(on: signal)
var stfftOLA = fourier.stfftOLA(on: signal)
let magsForDisplay = fourier.prepMagsForDisplay(stfft)



func bandForFreq(_ freq: Float, nyquistFreq: Int, numBands: Int) -> Int {
    let freqPerBand = nyquistFreq / numBands
    let band = freq / Float(freqPerBand)
    return Int(band)
}

// remove components
let nyquistFreq = Int(file.format.sampleRate / 2)
let numBands = size / 2
let lower = bandForFreq(3250, nyquistFreq: nyquistFreq, numBands: numBands)
let upper = bandForFreq(3750, nyquistFreq: nyquistFreq, numBands: numBands)
let range = lower..<upper
let length = range.upperBound - range.lowerBound - 1
let zeros = [Float](repeating: 0, count: length)

for complexBuffer in stfftOLA {
    complexBuffer.real.replaceSubrange(range, with: zeros)
    complexBuffer.imag.replaceSubrange(range, with: zeros)
}

let modifiedSignal = fourier.istfftOLA(on: stfftOLA)

let modifiedStfft = fourier.stfft(on: modifiedSignal)
let modifiedMags  = fourier.prepMagsForDisplay(modifiedStfft)

//: [Next](@next)

import PlaygroundSupport
import SwiftUI
PlaygroundPage.current.setLiveView(
    ManipulationView(
        origMags: magsForDisplay,
        modMags: modifiedMags,
        origSignal: signal,
        modSignal: modifiedSignal,
        sampleRate: file.format.sampleRate,
        origResolution: size / 2
    )
)
