/*:
 [Previous](@previous)

 # Manipulating The Components

 To return to the smoothie analogy, imagine if you made a large amount of mixed berry smoothie. However, someone that you were going to give it to doesn’t like blueberries. Un-blending the smoothie would allow you to remove those blueberries after the fact. That is effectively what we’re going to do to the high pitch squeal in this waveform.

 In the interest of speed and simplicity, this example will zero out the components we want to remove. In full applications, the modification process would be a lot more nuanced so it is not as destructive to the signal we want to save, but it would still be the same general idea.
 
 To demonstrate this removal I modified the piano track of The Lick by adding in a 3500 Hz sine wave. It's high enough that's its noticeable but not overly unpleasant (though I wouldn't recommend turning your speakers that high on this page).

*/

//: Let's first do a STFFT without OLA for display and with OLA for manipulation.
//: I wrote documentation for all methods of `Fourier`, so if you need a refresher just view quick help for them

let file = AudioInput.readFile(file: "lickRinging")
let signal = file.signal

let size = 512
let fourier = Fourier(size: size)

let stfftDisplay = fourier.stfft(on: signal)
var stfftOLA = fourier.stfftOLA(on: signal)

let origMags = fourier.prepMagsForDisplay(stfftDisplay)

/*:
 Now we need a way to find the index of the complex buffer which contains the frequency we want.
 
 The Nyquist frequency of the an audio file (which is the maximum frequency a file can support) is half of its sample rate.
 Because if a component has such a high frequency that the sample rate can't pick up on peaks, it won't be able to be stored.
 It is the top frequency of the top band, so it provides a hard ceiling, under which everything else can be equally distributed.
 
 A similar method is used in `Sources/Spectrogram/NSSpectrogramView.swift` in order to draw the y-axis frequency labels and the frequency guidelines.
*/
 
func bandForFreq(_ freq: Float, nyquistFreq: Int, numBands: Int) -> Int {
    let freqPerBand = nyquistFreq / numBands
    let band = freq / Float(freqPerBand)
    return Int(band)
}

//: Now let's remove the components that contain frequency information for the unwanted sine wave.

// For this example we'll remove frequencies 3250-3750 to remove all the ringing
// This range is demarcated by blue lines in the live view
// It snaps to the bottom of each band, which matches the behavior of bandForFreq (what is used for selecting the bands to zero out)
// So while the lines may not appear evenly centered in respect to the y-axis, it reflects where the operation actually will take place
let lowerFreq: Float = 3250
let upperFreq: Float = 3750

// Find the band range that correspond to the frequency range we want to remove
let nyquistFreq = Int(file.format.sampleRate / 2)
let numBands = size / 2

let lowerBand = bandForFreq(lowerFreq, nyquistFreq: nyquistFreq, numBands: numBands)
let upperBand = bandForFreq(upperFreq, nyquistFreq: nyquistFreq, numBands: numBands)
let range = lowerBand..<upperBand

// Create zero array to replace each section with
let length = range.count
let zeros = [Float](repeating: 0, count: length)

// Replace each section over time
for complexBuffer in stfftOLA {
    complexBuffer.real.replaceSubrange(range, with: zeros)
    complexBuffer.imag.replaceSubrange(range, with: zeros)
}

//: Now we can perform the inverse to get a signal from the modified components.

let modifiedSignal = fourier.istfftOLA(on: stfftOLA)

//: And perform a non-OLA forward to display on the spectrogram.

let modifiedStfft = fourier.stfft(on: modifiedSignal)
let modifiedMags  = fourier.prepMagsForDisplay(modifiedStfft)

/*:
 You may notice that black void we added in the manipulated spectrogram doesn't exactly match up with the frequency range we supposedly removed.
 That is due to the bands not lining up with a single frequency, but rather a group.
 If you remember from the first page, the "resolution" of the bands is determined by the window size.
 512 tends to be a good balance, but it's far from a 1:1 proportion.
 That sloppiness is why we had to remove a good chunk around 3500 Hz to remove the troublesome sine wave.
 
 The next page provides a live view interface to play with the concepts from the last three pages.
 
 __[Next](@next)__
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
        origResolution: size / 2,
        guidelines: [lowerFreq, upperFreq]
    )
)
