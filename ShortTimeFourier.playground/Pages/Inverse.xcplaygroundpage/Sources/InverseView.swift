//
//  InverseView.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/5/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import SwiftUI

public struct InverseView: View {
    @State private var magsForDisplay: [[Float]]
    
    // playback
    private var player: Player
    private var signalOrig: [Float]
    private var signalInvNoOLA: [Float]
    private var signalInvOLA: [Float]

    public init(
        magsForDisplay: [[Float]],
        signalOrig: [Float],
        signalInvNoOLA: [Float],
        signalInvOLA: [Float],
        sampleRate: Double
    ) {
        self._magsForDisplay = State(initialValue: magsForDisplay)
        self.player = Player(sampleRate: sampleRate)
        self.signalOrig = signalOrig
        self.signalInvNoOLA = signalInvNoOLA
        self.signalInvOLA = signalInvOLA
    }

    public var body: some View {
        VStack {
            SpectrogramView($magsForDisplay)
                .background(Color.black)

            HStack {
                Spacer()
                
                Button(action: {
                    self.play(self.signalOrig)
                }, label: {
                    Text("Play Original")
                })

                Button(action: {
                    self.play(self.signalInvNoOLA)
                }, label: {
                    Text("Play Inverse Without OLA")
                })
                
                Button(action: {
                    self.play(self.signalInvOLA)
                }, label: {
                    Text("Play Inverse With OLA")
                })

                Spacer()
            }.padding()
        }
            .frame(minWidth: 750, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
            .background(Color.black)
    }
    
    func play(_ signal: [Float]) {
        let buffer = player.makeBuffer(with: signal)
        player.play(buffer)
    }
}
