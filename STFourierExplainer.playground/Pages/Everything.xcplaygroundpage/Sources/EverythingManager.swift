//
//  EverythingManager.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/5/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

class EverythingManager: ObservableObject {
    // External
    @Published var file: AudioFile {
        didSet {
            fileUpdated()
        }
    }
    
    @Published var magsOrig: [[Float]] = []
    @Published var magsMod: [[Float]] = []
    
    @Published var sampleRate: Double = 0
    
    @Published var modifiedAvailable: Bool = false
    
    @Published var guidelines: [Float] = [0, 0]
    
    @Published var error = ""
    
    // Internal
    private var input: AVAudioPCMBuffer = AVAudioPCMBuffer()
    
    private var signal: [Float]      = []
    private var signalNoOLA: [Float] = []
    private var signalOLA: [Float]   = []
    private var signalMod: [Float]   = [] {
        didSet {
            modifiedAvailable = signalMod.count != 0
        }
    }

    // constants
    let chunkSize = 512
    @Published var origResolution = 256
    
    init() {
        self.file = .lick
        fileUpdated()
    }
    
    func fileUpdated() {
        self.input = AudioInput.readFile(file: file.rawValue)
        self.signal = input.signal
        self.sampleRate = input.format.sampleRate
        self.player = Player(sampleRate: sampleRate)
        calc()
    }

    func calc() {
        // reset mod
        signalMod = []
        magsMod = []
        
        let fourier = Fourier(size: chunkSize)
        
        // deconstruct
        let playFreqs    = fourier.stfftOLA(on: signal)
        let displayFreqs = fourier.stfft(on: signal)
        
        // get mags for display
        magsOrig = fourier.prepMagsForDisplay(displayFreqs)
        
        // reconstruct
        signalOLA = fourier.istfftOLA(on: playFreqs)
        signalNoOLA = fourier.istfft(on: displayFreqs)
    }
    
    func calcMod() {
        // get bands from freqs
        let lowerBand = bandForFreq(guidelines[0])
        let upperBand = bandForFreq(guidelines[1])
        
        // check that bands are valid
        if upperBand > origResolution {
            error = "Maximum is out of range"
            signalMod = []
            magsMod = []
            return
        } else if upperBand < lowerBand {
            error = "Minimum is greater than maximum"
            signalMod = []
            magsMod = []
            return
        } else if lowerBand < 0 {
            error = "Minimum is less than 0"
            signalMod = []
            magsMod = []
            return
        } else {
            error = ""
        }

        // Create zero array to replace each section with
        let range = lowerBand..<upperBand
        let length = range.count
        let zeros = [Float](repeating: 0, count: length)

        // Get what to replace
        let fourier = Fourier(size: chunkSize)
        let stfftOLA = fourier.stfftOLA(on: signal)
        
        // Replace
        for complexBuffer in stfftOLA {
            complexBuffer.real.replaceSubrange(range, with: zeros)
            complexBuffer.imag.replaceSubrange(range, with: zeros)
        }
        
        // signal from the modified components.
        signalMod = fourier.istfftOLA(on: stfftOLA)

        // non-OLA forward to display on the spectrogram.
        let modifiedStfft = fourier.stfft(on: signalMod)
        magsMod  = fourier.prepMagsForDisplay(modifiedStfft)
    }
    
    func bandForFreq(_ freq: Float) -> Int {
        let nyquistFreq = sampleRate / 2
        let freqPerBand = Float(nyquistFreq) / Float(origResolution)
        let band = freq / Float(freqPerBand)
        return Int(band)
    }
    
    // MARK: - Player
    private var player: Player = Player(sampleRate: 0)
    
    func play() {
        let buffer = player.makeBuffer(with: signal)
        player.play(buffer)
    }
    
    func playNoOLA() {
        let buffer = player.makeBuffer(with: signalNoOLA)
        player.play(buffer)
    }
    
    func playOLA() {
        let buffer = player.makeBuffer(with: signalOLA)
        player.play(buffer)
    }
    
    func playMod() {
        let buffer = player.makeBuffer(with: signalMod)
        player.play(buffer)
    }
}

