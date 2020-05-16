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
    
    // MARK: - Inputs
    public var magsOverTime: [[Float]] = []
    
    var nyquistFreq        = 0
    var originalResolution = 0
    var trimmedResolution  = 0
    
    var guidelines: [Float] = []
    
    // MARK: - Constants
    let textWidth: CGFloat = 50
    
    // MARK: - Drawing
    public override func draw(_ rect: CGRect) {
        if magsOverTime.isEmpty {
            return
        }
        guard let context = NSGraphicsContext.current?.cgContext else {
            print("could not get context")
            return
        }
        drawSpectrogram(context: context)
        drawLabels(context: context)
        drawGuidelines(context: context)
    }
    
    private func drawSpectrogram(context: CGContext) {
        // save context
        context.saveGState()
        
        // get sizes
        let viewWidth = self.bounds.size.width - textWidth
        let viewHeight = self.bounds.size.height
        
        let colWidth = viewWidth / CGFloat(magsOverTime.count)
        
        // get decibel range
        let maxDB: Float = 95.0
        let minDB: Float = -32.0
        let headroom = maxDB - minDB
        
        // draw
        var x: CGFloat = textWidth
        for mags in magsOverTime {
            let magsPerSet = mags.count
            let magRectHeight = viewHeight / CGFloat(magsPerSet)
            
            var y: CGFloat = 0
            for magnitude in mags {
                // set color to decibel percent of headroom
                let colorPercent = magnitude / headroom
                let color = rygGradient(at: CGFloat(colorPercent))
                context.setFillColor(color)
                
                // draw rectangle
                let path = CGRect(x: x, y: y, width: colWidth, height: magRectHeight)
                context.addRect(path)
                context.drawPath(using: .fill)
                
                // get next starting position
                y += magRectHeight
            }
            
            x += colWidth
        }
        
        // restore context
        context.restoreGState()
    }
    
    private func drawGuidelines(context: CGContext) {
        if guidelines.count == 0 {
            return
        }
        
        // setup context
        context.saveGState()
        context.setFillColor(NSColor.blue.cgColor)
        
        // get external sizes
        let viewHeight = self.bounds.size.height
        let viewWidth = self.bounds.size.width
        let heightPerBand = viewHeight / CGFloat(trimmedResolution)
        
        // calc rect sizes
        let x = textWidth
        let width = viewWidth - textWidth
        let height = heightPerBand / 2
        
        for freq in guidelines {
            let y = CGFloat(bandForFreq(freq)) * heightPerBand
            
            // draw rectangle
            let rect = CGRect(x: x, y: y, width: width, height: height)
            context.addRect(rect)
            context.drawPath(using: .fill)
        }
        
        // restore context
        context.restoreGState()
    }
    
    private func drawLabels(context: CGContext) {
        // save context
        context.saveGState()
        
        let viewHeight = CGFloat(self.bounds.size.height)
        
        // scale down the highest frequency of the original complex buffer to the highest frequency we are actually displaying
        let highestFreq = Int(CGFloat(nyquistFreq) * (CGFloat(trimmedResolution) / CGFloat(originalResolution)))
        
        // put a label every 500 hertz
        let freqBetweenLabels = 500
        let numLabels = Int(highestFreq / freqBetweenLabels)
        let unlabeledSpace = highestFreq % freqBetweenLabels
        let unlabeledRatio = CGFloat(highestFreq - unlabeledSpace) / CGFloat(highestFreq)
        
        // find how spaced out each label is
        let pixelsBetweenLabels = (viewHeight * unlabeledRatio) / CGFloat(numLabels)
        
        // draw all the labels
        for labelNumber in 0..<numLabels {
            drawString(String(freqBetweenLabels * labelNumber), x: 0, y: CGFloat(labelNumber) * pixelsBetweenLabels, context: context)
        }
        
        // restore context
        context.restoreGState()
    }
    
    // MARK: - Helper Funcs
    private func bandForFreq(_ freq: Float) -> Int {
        // scale down the highest frequency of the original complex buffer to the highest frequency we are actually displaying
        let highestFreq = Int(CGFloat(nyquistFreq) * (CGFloat(trimmedResolution) / CGFloat(originalResolution)))
        let freqPerBand = highestFreq / trimmedResolution
        let band = freq / Float(freqPerBand)
        return Int(band)
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

        let stringRect = CGRect(x: x, y: y, width: textWidth, height: 13)
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

