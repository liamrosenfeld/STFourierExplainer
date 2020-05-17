/*:
 [Previous](@previous)
 
 # The Inverse
 
 The inverse STFFT (ISTFFT) allow us to get the original signal from the complex buffer returned from the forward STFFT.
 
 ## How?
 
 Magnitudes tell us the frequencies of the components, but not their phase (the displacement across time of a wave). Luckily, the Accelerate FFT returns complex numbers (essentially acting as vectors) where the angle of the vector represents phase. We can then pass those complex numbers back into the IFFT to get the original signal. Since both the magnitude and the phase can be calculated from those complex number vectors, the IFFT can return a signal that is nearly identical to the original.
 
 */

//: Let's first do another forward STFFT.
//:
//: This has been moved to functions so it takes up less space.
let file = AudioInput.readFile(file: "lick")
let signal = file.signal

let size = 512
let fourier = Fourier(size: size)
let stfft = fourier.stfft(on: signal)
let magsForDisplay = fourier.prepMagsForDisplay(stfft)

//: Like the forward STFFT, the inverse STFFT is foundationally a series of FFTs.
//: However, this time they are the inverse FFT instead of the forward FFT.

import Accelerate

let fft = vDSP.FFT(ofSize: size)!
let window = vDSP.window(ofSize: size)

func ifft(complexBuffer: DSPSplitComplex) -> [Float] {
    // The inverse function returns a complex buffer that is then converted back into
    // an array of floats, so the output buffer needs to be half of the original chunk size
    let outputSize = size / 2
    let outputBuffer = ComplexBuffer(size: outputSize)
    
    // Now we can pass our complex buffer in and have it write the output to the output buffer
    fft.inverse(input: complexBuffer, output: &outputBuffer.split)
    
    // And then convert our complex buffer into an array of floats which is the original length
    let scale = 1 / Float(size * 2)
    return [Float](fromSplitComplex: outputBuffer.split, scale: scale, count: size)
}

//: For now, let's have our ISTFFT be the exact opposite of STFFT—we'll get into better methods soon.

let chunksAgain: [[Float]] = stfft.map { ifft(complexBuffer: $0.split) }
let signalAgain: [Float] = chunksAgain.flatMap { $0 }

/*:
 
 You can listen to that when you press the "Play Inverse Without OLA" on the live view. Not that you'll want to do that much—it's quite gross.
 
 Let's dig into the resulting waveform to see what caused this gross sound.
 
 Here is the original waveform compared to our inverse output in matplotlib:
 
 ![Non OLA inverse compared to original](non_ola_inverse.png)
 
 What this reveals is that it has peaks in the same position periodically, but often at different amplitudes.
 
 If you think back to the forward section you may remember a mention of a side effect of the windowing function—this is that side effect.
 
 Luckily, there is a method to work around it.
 
 ## The Overlap-Add Method (OLA)
 
 By doing OLA we’re able to have the inverse still include the components that were previously reduced.
 
 As you probably could figure the overlap-add method has two main components: overlapping and adding.
 
 The overlap component starts with the forward fourier transform. The chunks are taken from the signal where the starting position of the chunk only increases by a specific amount that is less than the chunk size. That distance will be referred to as the hop size. Since the hop size is less than the chunk size, the chunks will overlap.
 
 The add component then comes in during the inverse. After each chunk's complex buffer goes through the IFFT to turn back into signal, they are then recombined into the original signal, with overlapping sections adding together.
 
 1:2 is the standard overlap ratio so for higher quality regenerations that use more overlaps, the final signal needs to be scaled down by `overlapRatio / 2`
 
 Now let's dig into the code to make this happen.
 
 To demonstrate this, we first need to do a forward STFFT but have it overlap
 */

// Like the normal STFFT, we first need to divide the signal into chunks of size
// The difference is that now those chunks are overlapping
let overlapRatio = 4
let hop = size / overlapRatio
var chunks = signal.chunked(into: size, hop: hop)
chunks = chunks.map { $0.pad(to: size) }

// Then apply a FFT to each chunk individually, like the normal STFFT
let stfftOLA = chunks.map { fourier.fft(buffer: $0) }
    
//: Now let's do the inverse.
let chunksAgainOLA: [[Float]] = stfftOLA.map { ifft(complexBuffer: $0.split) }

/*:
 The updating results side bar is too expensive for this highly iterative operation.
 The operation would normally take an unnoticeable amount of time, but with the result side bar it takes 3 minutes.
 Because of that limitation in playgrounds, this section of notated code will be located in `InverseOLA.swift` in the `Sources` folder under this page and called as a function here.
 */

let signalAgainOLA = overlapAdd(chunksAgainOLA, size: size, hop: hop)

/*:
 Here is a copy of InverseOLA.swift:
 
 ```
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
 ```
 */

/*:
 
 Now if you listen to "Inverse With OLA" in the live view you can hear a reconstructed signal without it being a garbled mess.
 
 If we check on the signal in matplotlib we can see that, while there are slight discrepancies, it is largely the same:
 
 ![OLA inverse compared to original](ola_inverse.png)
 
 ## But why?
 
 You may be wondering what's the point of doing all this when the result is essentially what you already had.
 
 Other then it just being interesting, it's an opportunity to mess with the component frequencies to manipulate the waveform.
 
 [Next](@next)
*/

// MARK: - Display
import PlaygroundSupport
PlaygroundPage.current.setLiveView(
    InverseView(
        magsForDisplay: magsForDisplay,
        signalOrig: signal,
        signalInvNoOLA: signalAgain,
        signalInvOLA: signalAgainOLA,
        sampleRate: file.format.sampleRate,
        origResolution: size / 2
    )
)
