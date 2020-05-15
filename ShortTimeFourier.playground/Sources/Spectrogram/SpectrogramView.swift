//
//  SpectrogramView.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/5/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import SwiftUI

public struct SpectrogramView: NSViewRepresentable {
    @Binding var magsOverTime: [[Float]]
    @Binding var sampleRate: Double
    @Binding var origResolution: Int
    
    public init(
        _ magsOverTime: Binding<[[Float]]>,
        sampleRate: Binding<Double>,
        origResolution: Binding<Int>
    ) {
        self._magsOverTime = magsOverTime
        self._sampleRate   = sampleRate
        self._origResolution = origResolution
    }

    public func makeNSView(context: Context) -> NSSpectrogramView {
        return NSSpectrogramView()
    }

    public func updateNSView(_ nsView: NSSpectrogramView, context: Context) {
        nsView.magsOverTime = magsOverTime
        nsView.nyquistFreq = Int(sampleRate / 2)
        nsView.originalResolution = origResolution
        nsView.trimmedResolution = magsOverTime[0].count
        nsView.setNeedsDisplay(nsView.frame)
    }
}
