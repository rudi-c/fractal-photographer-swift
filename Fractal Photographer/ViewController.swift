//
//  ViewController.swift
//  Fractal Photographer
//
//  Created by Rudi Chen on 9/27/14.
//  Copyright (c) 2014 Digital Freepen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var renderView: UIImageView!

    let fractalModel = FractalModel()
    var renderImage : UIImage

    required init(coder aDecoder: NSCoder)
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(100, 100),
            false, 0.0);
        renderImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fractalModel.setSize(Int(renderView.bounds.size.width),
            Int(renderView.bounds.size.height))

        render()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // http://stackoverflow.com/questions/7650144/how-to-convert-bytearray-to-image-in-objective-c
    func rgba8ToImage(bytes: UnsafeMutablePointer<Byte>, width: Int, height: Int) -> UIImage {
        let byteLength = width * height * 4;

        let provider = CGDataProviderCreateWithData(nil, bytes, UInt(byteLength), nil);
        let bitsPerComponent : UInt = 8;
        let bitsPerPixel : UInt = 32;
        let bytesPerRow : UInt = 4 * UInt(width);

        let colorSpaceRef = CGColorSpaceCreateDeviceRGB();

        let bitmapInfo = CGBitmapInfo.fromRaw(CGBitmapInfo.ByteOrderDefault.toRaw() |
                                              CGImageAlphaInfo.PremultipliedLast.toRaw())
        let renderingIntent = kCGRenderingIntentDefault

        let iref = CGImageCreate(UInt(width),
            UInt(height),
            bitsPerComponent,
            bitsPerPixel,
            bytesPerRow,
            colorSpaceRef,
            bitmapInfo!,
            provider,   // data provider
            nil,       // decode
            true,            // should interpolate
            renderingIntent);

        let pixels = UnsafeMutablePointer<UInt32>.alloc(byteLength)

        let context = CGBitmapContextCreate(pixels,
            UInt(width),
            UInt(height),
            bitsPerComponent,
            bytesPerRow,
            colorSpaceRef,
            bitmapInfo!);

        let imageRect = CGRectMake(0, 0, CGFloat(width), CGFloat(height))
        CGContextDrawImage(context, imageRect, iref)
        let imageRef = CGBitmapContextCreateImage(context)
        let image = UIImage(CGImage: imageRef,
            scale: UIScreen.mainScreen().scale,
            orientation: UIImageOrientation.Up)

        pixels.dealloc(byteLength)
        return image;
    }

    func render() {
        fractalModel.render()
        renderView.image = rgba8ToImage(fractalModel.imageBytes,
            width: fractalModel.pixelWidth, height: fractalModel.pixelHeight)
    }
}

