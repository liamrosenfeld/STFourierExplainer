//
//  EverythingView.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/5/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import SwiftUI

public struct EverythingView: View {
    
    @ObservedObject private var manager = EverythingManager()
    
    public init() { }
    
    public var body: some View {
        VStack {
            Text("Original")
                .font(.headline)
                .foregroundColor(Color.white)
            
            SpectrogramView(
                $manager.magsOrig,
                sampleRate: $manager.sampleRate,
                origResolution: $manager.origResolution,
                guidelines: $manager.guidelines
            ).frame(width: 750, height: 600)

            HStack {
                Spacer()

                Picker("Audio:", selection: $manager.file) {
                    ForEach(audioFiles, id: \.self) {
                        Text($0).tag($0)
                    }
                }

                Spacer()

                Button(action: {
                    self.manager.play()
                }, label: {
                    Text("Play Original")
                })
                
                Button(action: {
                    self.manager.playNoOLA()
                }, label: {
                    Text("Play Reconstructed no OLA")
                })

                Button(action: {
                    self.manager.playOLA()
                }, label: {
                    Text("Play Reconstructed with OLA")
                })

                Spacer()
            }.padding()
            
            
            
            HStack {
                NumberField("Min Freq", value: $manager.guidelines[0])
                NumberField("Max Freq", value: $manager.guidelines[1])
                
                Button(action: {
                    self.manager.calcMod()
                }, label: {
                    Text("Calculate Manipulated")
                })
            }
            
            if manager.error != "" {
                Text(manager.error)
                    .foregroundColor(Color.red)
            }
            
            if manager.modifiedAvailable {
                Spacer()
                Spacer()
                
                Text("Manipulated")
                    .font(.headline)
                    .foregroundColor(Color.white)
                
                SpectrogramView(
                    $manager.magsMod,
                    sampleRate: $manager.sampleRate,
                    origResolution: $manager.origResolution
                ).frame(width: 750, height: 600)
                
                Button(action: {
                    self.manager.playMod()
                }, label: {
                    Text("Play Manipulated")
                })
                
            }
            
            Spacer()
        }.frame(minWidth: 750, maxWidth: .infinity, minHeight: 1450, maxHeight: .infinity).padding().background(Color.black)
    }
}

struct EverythingView_Previews: PreviewProvider {
    static var previews: some View {
        EverythingView()
    }
}
