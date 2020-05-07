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
    
    public init(_ magsOverTime: Binding<[[Float]]>) {
        self._magsOverTime = magsOverTime
    }

    public func makeNSView(context: Context) -> NSSpectrogramView {
        return NSSpectrogramView()
    }

    public func updateNSView(_ nsView: NSSpectrogramView, context: Context) {
        nsView.magsOverTime = magsOverTime
        nsView.setNeedsDisplay(nsView.frame)
    }
}
