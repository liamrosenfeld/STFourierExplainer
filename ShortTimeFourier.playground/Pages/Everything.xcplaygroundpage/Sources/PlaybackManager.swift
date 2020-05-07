//
//  PlaybackManager.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/5/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import Foundation
import AVFoundation
import Accelerate
import SwiftUI

class PlaybackManager: ObservableObject {
    // UI
    @Published var file: AudioFile {
        didSet {
            fileUpdated()
        }
    }
    
    @Published var magsForDisplay: [[Float]] = []
    
    // Internal
    private var input: AVAudioPCMBuffer = AVAudioPCMBuffer()
    private var sampleRate: Double = 0
    private var mags: [[Float]] = []
    private var signal: [Float] = []
    private var signalAgain: [Float] = []

    // constants
    let chunkSize = 512
    
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
        
        // make display
        mags = displayFreqs.map { freqSet in
            Fourier.magnitudes(for: freqSet.split, size: chunkSize / 2)
        }
        
        magsForDisplay = mags.zerosTrimmed.map {
            // these magnitudes are linear
            // which makes it hard to see very low or very high values
            // decibels to the rescue!
            let temp = vDSP.amplitudeToDecibels($0, zeroReference: 0.1)
            return temp
        }
        
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

struct Player {
    private let engine: AVAudioEngine
    private let playerNode: AVAudioPlayerNode
    private let sampleRate: Double
    
    init(sampleRate: Double) {
        self.sampleRate = sampleRate
        self.engine = AVAudioEngine()
        self.playerNode = AVAudioPlayerNode()
    }

    func makeBuffer(with signal: [Float]) -> AVAudioPCMBuffer {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format,
                                         frameCapacity: AVAudioFrameCount(signal.count))!
        pcmBuffer.frameLength = pcmBuffer.frameCapacity

        // probably could be a non iterative approach where Data is copied directly
        let floatData = pcmBuffer.floatChannelData![0]
        for (index, frame) in signal.enumerated() {
            floatData[index] = frame
        }

        return pcmBuffer

    }

    func play( _ buffer: AVAudioPCMBuffer) {
        // engine config
        let mixer = engine.outputNode
        engine.attach(playerNode)
        engine.connect(playerNode, to: mixer, format: buffer.format)
        try! engine.start()

        // play
        playerNode.play()
        playerNode.scheduleBuffer(buffer, completionHandler: nil)

    }
}

enum AudioFile: String, CaseIterable {
    case lick
    case lickOctaves
    case lickChords
    case oneNote
}
