/*:
 Here's a page where you can play around with everything in one UI

 _[Back to start](Forward)_
 */

import PlaygroundSupport
let view = EverythingView()
PlaygroundPage.current.setLiveView(view)

/*:
 ## Going Further: Overtones
 
 Timbre (pronounced tam-ber) is the unique sound of an instrument. Tone is then the quality of sound within the predefined range if the instrument. The natural phenomena of overtones contributes greatly to both.
 
 It may seem intuitive that the file "oneNote" would only have one frequency. However, a quick toss into the spectrogram would show that is not the case.
 
 While the fundamental frequency is still the most prominent, there are several overtones above that fundamental pitch.
 
 Try using the modifier to remove some (or all) of the overtones and listening to how it affects the timbre of the clip. The easiest to do this on is `oneNote`.
 
 If you want to remove all the overtones from `oneNote` try the range 700-4000. For `lick`, try 600-5000.
 
 If you would like to learn more about overtones, a good place to start off would be [Andrew Huang's video](https://youtu.be/Wx_kugSemfY) .
 */

/*:
 ## Main Sources Used
 
 - [Short-Time Fourier Transform and Its Inverse by Ivan W. Selesnick](http://eeweb.poly.edu/iselesni/EL713/STFT/stft_inverse.pdf)
 - [Spectral Analysis, Editing, and Resynthesis: Methods and Applications by Michael Kateley Klingbeil](http://www.klingbeil.com/data/Klingbeil_Dissertation_web.pdf)
 - [FFT convolution and the overlap-add method by Steven W. Smith](https://www.eetimes.com/fft-convolution-and-the-overlap-add-method/#)
 - [Lecture by Mike Cohen](https://youtu.be/8nZrgJjl3wc)
 
 */
