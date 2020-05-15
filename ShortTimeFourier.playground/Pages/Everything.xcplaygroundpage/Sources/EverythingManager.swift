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
    
    @Published var magsForDisplay: [[Float]] = []
    
    @Published var sampleRate: Double = 0
    
    // Internal
    private var input: AVAudioPCMBuffer = AVAudioPCMBuffer()
    private var signal: [Float] = []
    private var signalAgain: [Float] = []

    // constants
    let chunkSize = 512
    var origResolution = Binding.constant(256)
    
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
        let fourier = Fourier(size: chunkSize)
        
        // deconstruct
        let playFreqs    = fourier.stfftOLA(on: signal)
        let displayFreqs = fourier.stfft(on: signal)
        
        // get mags for display
        magsForDisplay = fourier.prepMagsForDisplay(displayFreqs)
        
        // reconstruct
        signalAgain = fourier.istfftOLA(on: playFreqs)
    }
    
    // MARK: - Player
    private var player: Player = Player(sampleRate: 0)
    
    func play() {
        let buffer = player.makeBuffer(with: signal)
        player.play(buffer)
    }
    
    func playReconstructed() {
        let buffer = player.makeBuffer(with: signalAgain)
        player.play(buffer)
    }
}

