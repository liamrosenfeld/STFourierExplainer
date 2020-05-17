//
//  NumberField.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/16/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import SwiftUI

struct NumberField : View {
    
    private let label: String
    @Binding var value: Float
    @State private var textValue: String = ""
    @State private var didAppear = false
    
    init(
        _ label: String,
        value: Binding<Float>
    ) {
        self.label = label
        self._value = value
    }
    
    var body: some View {
        HStack {
            Text("\(label):")
            TextField("", text: Binding(get: {
                self.textValue
            }, set: { newValue in
                self.textValue = newValue
                self.updateValue(with: newValue)
            }))
        }.onAppear() {
            self.textValue = self.value.description
            self.didAppear = true
        }
        
    }
    
    private func updateValue(with input: String) {
        guard didAppear else { return }
        
        if let num = Float(input) {
            self.value = num
        } else {
            self.textValue = self.value.description
        }
    }

}
