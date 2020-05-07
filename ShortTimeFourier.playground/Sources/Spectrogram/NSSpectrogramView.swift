//
//  NSSpectrogramView.swift
//  ShortTimeFourier
//
//  Created by Liam Rosenfeld on 5/5/20.
//  Copyright © 2020 Liam Rosenfeld. All rights reserved.
//

import AppKit

public class NSSpectrogramView: NSView {
    
    public var magsOverTime: [[Float]] = []
    
    public override func draw(_ rect: CGRect) {
        if magsOverTime.isEmpty {
            return
        }
        drawSpectrogram()
    }
    
    private func drawSpectrogram() {
        // setup core graphics context
        guard let context = NSGraphicsContext.current?.cgContext else {
            print("could not get context")
            return
        }
        context.saveGState()
        
        // get sizes
        let viewWidth = self.bounds.size.width
        let viewHeight = self.bounds.size.height
        
        let colWidth = viewWidth / CGFloat(magsOverTime.count)
        
        // get decible range
        let maxDB: Float = 95.0
        let minDB: Float = -32.0
        let headroom = maxDB - minDB
        
        // draw
        var x: CGFloat = 0
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
    
    /// Find the color at a point along a Red-Yellow-Green Gradient
    /// - Parameter percent: the percent along the gradient. must be in the range [0, 1]
    ///
    /// If the percent is below 0.15 it additionally reduces the opacity proportionally
    func rygGradient(at percent: CGFloat) -> CGColor {
        if percent <= 0.15 {
            return CGColor(srgbRed: percent * 2, green: 1, blue: 0, alpha: percent / 0.2)
        } else if percent <= 0.50 {
            return CGColor(srgbRed: percent * 2, green: 1, blue: 0, alpha: 1)
        } else {
            return CGColor(srgbRed: 1, green: 1 - ((percent - 0.5) * 2), blue: 0, alpha: 1)
        }
    }
}

