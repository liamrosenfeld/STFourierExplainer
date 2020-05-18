//
//  InverseView.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/5/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import SwiftUI

public struct InverseView: View {
    // spectrogram
    @State private var magsForDisplay: [[Float]]
    @State private var sampleRate: Double
    @State private var origResolution: Int
    
    // playback
    private var player: Player
    private var signalOrig: [Float]
    private var signalInvNoOLA: [Float]
    private var signalInvOLA: [Float]
    
    @State private var playing = false
    
    public init(
        magsForDisplay: [[Float]],
        signalOrig: [Float],
        signalInvNoOLA: [Float],
        signalInvOLA: [Float],
        sampleRate: Double,
        origResolution: Int
    ) {
        // playback
        self.player = Player(sampleRate: sampleRate)
        self.signalOrig = signalOrig
        self.signalInvNoOLA = signalInvNoOLA
        self.signalInvOLA = signalInvOLA
        
        // spectrogram
        self._magsForDisplay = State(initialValue: magsForDisplay)
        self._sampleRate = State(initialValue: sampleRate)
        self._origResolution = State(initialValue: origResolution)
    }

    public var body: some View {
        VStack {
            SpectrogramView(
                $magsForDisplay,
                sampleRate: $sampleRate,
                origResolution: $origResolution
            ).background(Color.black)

            HStack {
                Spacer()
                
                Button(action: {
                    self.play(self.signalOrig)
                }, label: {
                    Text("Play Original")
                }).disabled(self.playing)

                Button(action: {
                    self.play(self.signalInvNoOLA)
                }, label: {
                    Text("Play Inverse Without OLA")
                }).disabled(self.playing)
                
                Button(action: {
                    self.play(self.signalInvOLA)
                }, label: {
                    Text("Play Inverse With OLA")
                }).disabled(self.playing)

                Spacer()
            }.padding()
        }
            .frame(minWidth: 750, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
            .background(Color.black)
    }
    
    func play(_ signal: [Float]) {
        let buffer = player.makeBuffer(with: signal)
        playing = true
        player.play(buffer) {
            self.playing = false
        }
    }
}
