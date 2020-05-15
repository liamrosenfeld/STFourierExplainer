/*:
[Previous](@previous)

# Manipulating The Components

To return to the smoothie analogy, imagine if you made a large amount of mixed berry smoothie. However, someone that you were going to give it to doesn’t like blueberries. Un-blending the smoothie would allow you to remove those blueberries after the fact. That is effectively what we’re going to do to the ringing in this waveform.

## How?

[.......]

*/

//: Let's first do a STFFT without OLA for display and with OLA for manipulation

let file = AudioInput.readFile(file: "lick")
let signal = file.signal

let size = 512
let fourier = Fourier(size: size)
let stfft = fourier.stfft(on: signal)
let stfftOLA = fourier.stfftOLA(on: signal)
let magsForDisplay = fourier.prepMagsForDisplay(stfft)



let signalAgain = fourier.istfftOLA(on: stfftOLA)







let player = Player(sampleRate: file.format.sampleRate)
let buffer = player.makeBuffer(with: signalAgain)
player.play(buffer)

//: [Next](@next)
