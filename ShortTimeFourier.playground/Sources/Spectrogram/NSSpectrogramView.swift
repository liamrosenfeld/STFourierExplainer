//
//  NSSpectrogramView.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/5/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import AppKit
import CoreGraphics

public class NSSpectrogramView: NSView {
    
    public var magsOverTime: [[Float]] = []
    
    let labelWidth: CGFloat = 50
    
    var nyquistFreq        = 0
    var originalResolution = 0
    var trimmedResolution  = 0
    
    public override func draw(_ rect: CGRect) {
        if magsOverTime.isEmpty {
            return
        }
        drawSpectrogram()
        drawLabels()
    }
    
    private func drawSpectrogram() {
        // setup core graphics context
        guard let context = NSGraphicsContext.current?.cgContext else {
            print("could not get context")
            return
        }
        context.saveGState()
        
        // get sizes
        let viewWidth = self.bounds.size.width - labelWidth
        let viewHeight = self.bounds.size.height
        
        let colWidth = viewWidth / CGFloat(magsOverTime.count)
        
        // get decible range
        let maxDB: Float = 95.0
        let minDB: Float = -32.0
        let headroom = maxDB - minDB
        
        // draw
        var x: CGFloat = 50 // leave room for text on side
        for mags in magsOverTime {
            let magsPerSet = mags.count
            let magRectHeight = viewHeight / CGFloat(magsPerSet)
            
            var y: CGFloat = 0
            for magnitude in mags {
                // set color to decible percent of headroom
                let colorPercent = magnitude / headroom
                let color = rygGradient(at: CGFloat(colorPercent))
                context.setFillColor(color)
                
                // draw rectange
                let path = CGRect(x: x, y: y, width: colWidth, height: magRectHeight)
                context.addRect(path)
                context.drawPath(using: .fill)
                
                // get next starting position
                y += magRectHeight
            }
            
            x += colWidth
        }
        
        // restore cg context state
        context.restoreGState()
    }
    
    private func drawLabels() {
       // setup core graphics context
        guard let context = NSGraphicsContext.current?.cgContext else {
            print("could not get context")
            return
        }
        context.saveGState()
        
        let viewHeight = CGFloat(self.bounds.size.height)
        
        // scale down the highest frequency of the original complex buffer to the highest frequency we are actually displaying
        let heighestFreq = Int(CGFloat(nyquistFreq) * (CGFloat(trimmedResolution) / CGFloat(originalResolution)))
        
        // spread out the labels a bit so it's not too cluttered
        let amountOfLabels = trimmedResolution / 10
        
        // find how much goes to each label
        let freqBetweenLabels = heighestFreq / amountOfLabels
        let pixelsBetweenLabels = viewHeight / CGFloat(amountOfLabels)
        
        // draw all the labels
        for labelNumber in 0..<amountOfLabels {
            drawString(String(freqBetweenLabels * labelNumber), x: 0, y: CGFloat(labelNumber) * pixelsBetweenLabels, context: context)
        }
        
        // restore cg context state
        context.restoreGState()
    }
    
    private func drawString(_ string: String, x: CGFloat, y: CGFloat, context: CGContext) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .font: NSFont.systemFont(ofSize: 12.0),
            .foregroundColor: NSColor.white
        ]

        let attributedString = NSAttributedString(string: string, attributes: attributes)

        let stringRect = CGRect(x: x, y: y, width: labelWidth, height: 12)
        attributedString.draw(in: stringRect)
    }
    
    /// Find the color at a point along a Red-Yellow-Green Gradient
    /// - Parameter percent: the percent along the gradient. must be in the range [0, 1]
    ///
    /// If the percent is below 0.15 it additionally reduces the opacity proportionally
    private func rygGradient(at percent: CGFloat) -> CGColor {
        if percent <= 0.15 {
            return CGColor(srgbRed: percent * 2, green: 1, blue: 0, alpha: percent / 0.2)
        } else if percent <= 0.50 {
            return CGColor(srgbRed: percent * 2, green: 1, blue: 0, alpha: 1)
        } else {
            return CGColor(srgbRed: 1, green: 1 - ((percent - 0.5) * 2), blue: 0, alpha: 1)
        }
    }
}

