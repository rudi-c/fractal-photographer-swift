//
//  FractalModel.swift
//  Fractal Photographer
//
//  Created by Rudi Chen on 9/27/14.
//  Copyright (c) 2014 Digital Freepen. All rights reserved.
//

import Foundation

class FractalModel {
    var offsetX: Double = 0.0
    var offsetY: Double = 0.0
    var zoom: Double = 1.0
    var maxIterations: Int = 30

    var _pixelWidth: Int = 0;
    var _pixelHeight: Int = 0;
    var pixelWidth: Int {
        get { return _pixelWidth; }
    }
    var pixelHeight: Int  {
        get { return _pixelHeight; }
    }

    var imageBytes : UnsafeMutablePointer<Byte>;

    init() {
        imageBytes = nil;
    }

    func setSize(p: (Int, Int)) {
        let oldByteLength = _pixelWidth * _pixelHeight * 4
        (_pixelWidth, _pixelHeight) = p
        let newByteLength = _pixelWidth * _pixelHeight * 4

        if (imageBytes != nil) {
            imageBytes.destroy(oldByteLength)
        }
        imageBytes = UnsafeMutablePointer<Byte>.alloc(newByteLength)
    }

    func render() {
        // Take away the red pixel, assuming 32-bit RGBA
        for var y = 0; y < _pixelHeight; y++ {
            for var x = 0; x < _pixelWidth; x++ {
                let i = (x + y * _pixelWidth) * 4;
                let (r, g, b) = renderAt((x, y))
                imageBytes[i] = r; // red
                imageBytes[i+1] = g; // green
                imageBytes[i+2] = b; // blue
                imageBytes[i+3] = 255; // alpha
            }
        }
    }

    func renderAt(p: (Int, Int)) -> (Byte, Byte, Byte) {
        let (x, y) = p
        let cx = Double(x) / Double(_pixelWidth) / zoom
        let cy = Double(y) / Double(_pixelHeight) / zoom
        var zx = cx
        var zy = cy

        var iterations = maxIterations

        for i in 1...maxIterations {
            // (x + yi) * (x + yi) = (x^2 - y^2) + 2xyi
            let zxsqr = zx * zx
            let zysqr = zy * zy

            if (zxsqr + zysqr > 4.0) {
                iterations = i
                break;
            }

            zy = 2 * zx * zy
            zx = zxsqr - zysqr
            zx += cx
            zy += cy
        }

        let fIter = Double(iterations)
        let r = Byte(255.0 * (1.0 + sin(fIter * 1.0)) / 2.0)
        let b = Byte(255.0 * (1.0 + sin(fIter * 1.3)) / 2.0)
        let g = Byte(255.0 * (1.0 + sin(fIter * 1.8)) / 2.0)
        return (r, b, g)
    }
}
