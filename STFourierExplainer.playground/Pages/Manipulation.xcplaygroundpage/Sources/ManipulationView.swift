//
//  ForwardView.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/15/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import SwiftUI

public struct ManipulationView: View {
    @State var origMags: [[Float]]
    @State var modMags: [[Float]]
    
    @State var origSignal: [Float]
    @State var modSignal: [Float]
    
    @State var sampleRate: Double
    @State var origResolution: Int
    
    private var player: Player
    
    public init(
        origMags: [[Float]],
        modMags: [[Float]],
        origSignal: [Float],
        modSignal: [Float],
        sampleRate: Double,
        origResolution: Int
    ) {
        self._origMags = State(initialValue: origMags)
        self._modMags = State(initialValue: modMags)
        
        self._origSignal = State(initialValue: origSignal)
        self._modSignal = State(initialValue: modSignal)
        
        self._sampleRate = State(initialValue: sampleRate)
        self._origResolution = State(initialValue: origResolution)
        
        self.player = Player(sampleRate: sampleRate)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Original")
                    .font(.title)
                    .foregroundColor(Color.white)
                Button(action: {
                    self.play(self.origSignal)
                }, label: {
                    Text("Play")
                })
            }
            SpectrogramView($origMags, sampleRate: $sampleRate, origResolution: $origResolution)
                .frame(minWidth: 750, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                .padding()
            
            
            Spacer()
            
            HStack {
                Text("Manipulated")
                    .font(.title)
                    .foregroundColor(Color.white)
                Button(action: {
                    self.play(self.modSignal)
                }, label: {
                    Text("Play")
                })
            }
            SpectrogramView($modMags, sampleRate: $sampleRate, origResolution: $origResolution)
                .frame(minWidth: 750, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                .padding()
        }.padding().background(Color.black)
    }
    
    func play(_ signal: [Float]) {
        let buffer = player.makeBuffer(with: signal)
        player.play(buffer)
    }
}
