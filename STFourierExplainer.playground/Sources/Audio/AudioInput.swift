//
//  AudioInput.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/5/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import Foundation
import AVFoundation

public struct AudioInput {
    public static func readFile(file: String) -> AVAudioPCMBuffer {
        let url = Bundle.main.url(forResource: file, withExtension: "wav")!
        let file = try! AVAudioFile(forReading: url)
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: 1, interleaved: false)!

        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))!
        try! file.read(into: buf)
        return buf
    }
}

public extension AVAudioPCMBuffer {
    var signal: [Float] {
        Array(UnsafeBufferPointer(start: self.floatChannelData?[0], count: Int(self.frameLength)))
    }
}

public enum AudioFile: String, CaseIterable {
    case lick
    case lickOctaves
    case lickChords
    case oneNote
}
