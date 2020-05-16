/*:
 [Previous](@previous)

 # Manipulating The Components

 To return to the smoothie analogy, imagine if you made a large amount of mixed berry smoothie. However, someone that you were going to give it to doesn’t like blueberries. Un-blending the smoothie would allow you to remove those blueberries after the fact. That is effectively what we’re going to do to the ringing in this waveform.

 In the interest of speed and simplicity, this example will just zero out the components we want to remove. In full applications the modification process would be a lot more nuanced so it is not as destructive to the signal we want to save, but it would still be the same general idea.
 
 To demonstrate this removal I modified the piano track of the lick by adding in a 3500 Hz sine wave. It's high enough that's its noticeable but not overly unpleasant (though I wouldn't recommend turning your speakers that high on this page).

*/

//: Let's first do a STFFT without OLA for display and with OLA for manipulation

let file = AudioInput.readFile(file: "lickRinging")
let signal = file.signal

let size = 512
let fourier = Fourier(size: size)

let stfftDisplay = fourier.stfft(on: signal)
var stfftOLA = fourier.stfftOLA(on: signal)

let origMags = fourier.prepMagsForDisplay(stfftDisplay)

/*:
 Now we need a way to translate from what frequency we want into the respective index of the complex buffer.
 
 The Nyquist frequency of the an audio file (which is the maximum frequency a file can support) is half of it's sample rate.
 
 That is because if a component as such a high frequency that the sample rate can't pick up on peaks, it won't be able to be stored.
 
 It is the top frequency of the top band, so it provides a hard ceiling that everything else can be equally distributed under.
 
 This same function is used in global `Sources/Spectrogram/NSSpectrogramView.swift` in order to draw the y-axis frequency labels.
*/
 
func bandForFreq(_ freq: Float, nyquistFreq: Int, numBands: Int) -> Int {
    let freqPerBand = nyquistFreq / numBands
    let band = freq / Float(freqPerBand)
    return Int(band)
}

//: Now let's remove the components that contain frequency information for the unwanted sine wave

// find the band range that correspond to the frequency range we want to remove
let nyquistFreq = Int(file.format.sampleRate / 2)
let numBands = size / 2
let lower = bandForFreq(3250, nyquistFreq: nyquistFreq, numBands: numBands)
let upper = bandForFreq(3750, nyquistFreq: nyquistFreq, numBands: numBands)
let range = lower..<upper

// create zero array to replace each section with
let length = range.upperBound - range.lowerBound - 1
let zeros = [Float](repeating: 0, count: length)

// replace each section over time
for complexBuffer in stfftOLA {
    complexBuffer.real.replaceSubrange(range, with: zeros)
    complexBuffer.imag.replaceSubrange(range, with: zeros)
}

//: Now we can do the inverse to get a signal from the modified components

let modifiedSignal = fourier.istfftOLA(on: stfftOLA)

//: And do a non OLA forward to display on the spectrogram

let modifiedStfft = fourier.stfft(on: modifiedSignal)
let modifiedMags  = fourier.prepMagsForDisplay(modifiedStfft)

/*:
 You may notice that black void we added in the manipulated spectrogram doesn't exactly match up with the frequency range we supposedly removed.
 That's because the affects the bands don't line up with a single frequency, but rather a couple close together.
 If you remember from the first page, the "resolution" of the bands is determined by the window size.
 512 tends to be a good balance, but it's far from a 1:1 proportion.
 That sloppiness is why we had to remove a good chunk around 3500 Hz to remove the troublesome sine wave.
 
 The next page provides a live view interface to play with the concepts from the last three pages
 
 [Next](@next)
 */

// MARK: - Display
import PlaygroundSupport
PlaygroundPage.current.setLiveView(
    ManipulationView(
        origMags: origMags,
        modMags: modifiedMags,
        origSignal: signal,
        modSignal: modifiedSignal,
        sampleRate: file.format.sampleRate,
        origResolution: size / 2
    )
)
