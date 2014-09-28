//
//  ViewController.swift
//  Fractal Photographer
//
//  Created by Rudi Chen on 9/27/14.
//  Copyright (c) 2014 Digital Freepen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var renderView: UIImageView!
    @IBOutlet var displayView: UIImageView!

    let fractalModel = FractalModel()
    var renderImage : UIImage

    var originalCenter = CGPoint()
    var originalCenterPinch = CGPoint()

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

        let panRecognizer = UIPanGestureRecognizer(target: self,
            action:Selector("handlePan:"))
        panRecognizer.delegate = self
        view.addGestureRecognizer(panRecognizer)

        let pinchRecognizer = UIPinchGestureRecognizer(target: self,
            action:Selector("handlePinch:"))
        pinchRecognizer.delegate = self
        view.addGestureRecognizer(pinchRecognizer)

        let bounds = UIScreen.mainScreen().bounds
        fractalModel.setSize(Int(bounds.size.width), Int(bounds.size.height))

        originalCenter = renderView.center

        render()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func gestureRecognizer(UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            // Currently, it's a bit hard to handle scale and pan at the same time.
            return false
    }

    func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case UIGestureRecognizerState.Began:
            originalCenterPinch = renderView.center
        case UIGestureRecognizerState.Ended:
            fractalModel.translate(
                Double(originalCenter.x - renderView.center.x),
                Double(originalCenter.y - renderView.center.y))
            render()
            renderView.center = originalCenter
        default:
            let translation = recognizer.translationInView(renderView)
            renderView.center = CGPoint(x:renderView.center.x + translation.x,
                y:renderView.center.y + translation.y)
            recognizer.setTranslation(CGPointZero, inView: renderView)
        }
    }

    func handlePinch(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case UIGestureRecognizerState.Began:
            originalCenterPinch = renderView.center
        case UIGestureRecognizerState.Ended:
            let t = renderView.transform

            // The two should be the same.
            let xscale = sqrt(t.a * t.a + t.c * t.c)
            let yscale = sqrt(t.b * t.b + t.d * t.d)

            renderView.transform = CGAffineTransformIdentity
            renderView.center = originalCenter
            render()
        default:
            fractalModel.zoom *= Double(recognizer.scale)
            renderView.transform = CGAffineTransformScale(renderView.transform,
                recognizer.scale, recognizer.scale)
            recognizer.scale = 1
        }
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

