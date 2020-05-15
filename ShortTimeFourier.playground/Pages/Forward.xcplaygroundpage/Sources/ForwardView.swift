//
//  ForwardView.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/5/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import SwiftUI

public struct ForwardView: View {
    @State var magsOverTime: [[Float]]
    @State var sampleRate: Double
    @State var origResolution: Int
    
    public init(_ magsOverTime: [[Float]], sampleRate: Double, origResolution: Int) {
        self._magsOverTime = State(initialValue: magsOverTime)
        self._sampleRate = State(initialValue: sampleRate)
        self._origResolution = State(initialValue: origResolution)
    }
    
    public var body: some View {
        SpectrogramView($magsOverTime, sampleRate: $sampleRate, origResolution: $origResolution)
            .frame(minWidth: 750, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
            .padding()
            .background(Color.black)
    }
}
