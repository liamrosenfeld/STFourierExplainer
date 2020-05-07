//
//  EverythingView.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/5/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import SwiftUI

public struct EverythingView: View {
    @ObservedObject private var manager = PlaybackManager()
    
    public init() { }
    
    public var body: some View {
        VStack{
            SpectrogramView($manager.magsForDisplay)
                .background(Color.black)
            
            HStack {
                Spacer()
                
                Picker("Audio:", selection: $manager.file) {
                    ForEach(AudioFile.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    self.manager.play()
                }, label: {
                    Text("Play")
                })
                
                Button(action: {
                    self.manager.playReconstructed()
                }, label: {
                    Text("Play Reconstructed")
                })
                
                Spacer()
            }.padding()
        }
            .frame(minWidth: 1000, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
            .background(Color.black)
    }
}


struct EverythingView_Previews: PreviewProvider {
    static var previews: some View {
        EverythingView()
    }
}
