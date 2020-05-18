//
//  Player.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/5/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import AVFoundation

public struct Player {
    private let engine: AVAudioEngine
    private let playerNode: AVAudioPlayerNode
    private let sampleRate: Double
    
    public init(sampleRate: Double) {
        self.sampleRate = sampleRate
        self.engine = AVAudioEngine()
        self.playerNode = AVAudioPlayerNode()
    }

    public func makeBuffer(with signal: [Float]) -> AVAudioPCMBuffer {
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

    public func play( _ buffer: AVAudioPCMBuffer, _ completionHandler: AVAudioNodeCompletionHandler? = nil) {
        // engine config
        let mixer = engine.outputNode
        engine.attach(playerNode)
        engine.connect(playerNode, to: mixer, format: buffer.format)
        try! engine.start()

        // play
        playerNode.play()
        playerNode.scheduleBuffer(buffer, completionHandler: completionHandler)

    }
}
