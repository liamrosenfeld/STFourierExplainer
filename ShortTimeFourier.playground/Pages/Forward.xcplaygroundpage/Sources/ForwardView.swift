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
    
    public init(_ magsOverTime: [[Float]]) {
        self._magsOverTime = State(initialValue: magsOverTime)
    }
    
    public var body: some View {
        SpectrogramView($magsOverTime)
            .frame(minWidth: 750, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
            .background(Color.black)
    }
}
