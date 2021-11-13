//
//  CropView.swift
//  CropViewController
//
//  Created by Guilherme Moura on 2/25/16.
//  Copyright © 2016 Reefactor, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class CropView: UIView {
    var image: UIImage? {
        didSet {
            if let image = image {
                self.imageSize = image.size
            }
        }
    }
    
    var imageView: UIView? {
        didSet {
            if let view = imageView, image == nil {
                self.imageSize = view.frame.size
            }
        }
    }
    
    var croppedImage: UIImage? {
        return image?.rotatedImageWithTransform(rotation, croppedToRect: zoomedCropRect())
    }
    
    var rotation: CGAffineTransform {
        set {
            if let imgView = imageView {
                self.imageView!.transform = imgView.transform.rotated(by: .pi / 2)    // 90˚
//                self.imageView?.transform = newValue
            }
        }
        get {
            guard let imgView = imageView else {
                return CGAffineTransform.identity
            }
            return imgView.transform
        }
    }
    
//    var rotationAngle: CGRect {
//        set {
//            zoomToCropRect(newValue)
//        }
//        get {
//            return scrollView.frame
//        }
//    }
        
    var imageSize = CGSize(width: 1.0, height: 1.0)
    var scrollView: UIScrollView!
    var zoomingView: UIView?
    let cropRectView = CropRectView()
    var insetRect = CGRect.zero
    var editingRect = CGRect.zero
    var resizing = false
    
    let marginTop: CGFloat = 44.0
    let marginLeft: CGFloat = 44.0

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    func initialize() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = UIColor.clear
        
        scrollView = UIScrollView(frame: bounds)
        scrollView.delegate = self
        scrollView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
        scrollView.backgroundColor = UIColor.clear
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        addSubview(scrollView)
        
        cropRectView.delegate = self
        cropRectView.isHidden = true
        addSubview(cropRectView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupEditingRect()

        if imageView == nil {
            insetRect = bounds.insetBy(dx: marginLeft, dy: marginTop)
            setupZoomingView()
            setupImageView()
        }
        
        resizing ? nil : layoutCropRectViewWithCropRect(scrollView.frame)
    }
    
    func zoomedCropRect() -> CGRect {
        let cropRect = convert(scrollView.frame, to: zoomingView)
        var ratio: CGFloat = 1.0
        let orientation = UIApplication.shared.statusBarOrientation
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad || orientation.isPortrait) {
            ratio = AVMakeRect(aspectRatio: imageSize, insideRect: insetRect).width / imageSize.width
        } else {
            ratio = AVMakeRect(aspectRatio: imageSize, insideRect: insetRect).height / imageSize.height
        }

        let zoomedCropRect = CGRect(x: cropRect.origin.x / ratio,
            y: cropRect.origin.y / ratio,
            width: cropRect.size.width / ratio,
            height: cropRect.size.height / ratio)
        
        return zoomedCropRect
    }
    
    func setupEditingRect() {
        editingRect = bounds.insetBy(dx: marginLeft, dy: marginTop)
    }
    
    func setupZoomingView() {
        let cropRect = AVMakeRect(aspectRatio: imageSize, insideRect: insetRect)
        
        scrollView.frame = cropRect
        scrollView.contentSize = cropRect.size
        
        zoomingView = UIView(frame: scrollView.bounds)
        zoomingView?.backgroundColor = .clear
        scrollView.addSubview(zoomingView!)
    }

    func setupImageView() {
        let imageView = UIImageView(frame: zoomingView!.bounds)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        zoomingView?.addSubview(imageView)
        self.imageView = imageView
    }
    
    func layoutCropRectViewWithCropRect(_ cropRect: CGRect) {
        cropRectView.frame = cropRect
    }
    
    func zoomToCropRect(_ toRect: CGRect) {
        if scrollView.frame.equalTo(toRect) { return }

        let width = toRect.width
        let height = toRect.height
        let scale = min(editingRect.width / width, editingRect.height / height)

        let scaledWidth = width * scale
        let scaledHeight = height * scale
        let cropRect = CGRect(x: (bounds.width - scaledWidth) / 2.0, y: (bounds.height - scaledHeight) / 2.0, width: scaledWidth, height: scaledHeight)

        var zoomRect = convert(toRect, to: zoomingView)
        zoomRect.size.width = cropRect.width / (scrollView.zoomScale * scale)
        zoomRect.size.height = cropRect.height / (scrollView.zoomScale * scale)

        UIView.animate(withDuration: 0.25, delay: 0.0, options: .beginFromCurrentState, animations: { [unowned self] in
            self.scrollView.bounds = cropRect
            self.scrollView.zoom(to: zoomRect, animated: false)
            self.layoutCropRectViewWithCropRect(cropRect)
        })
    }
    
    func cappedCropRectInImageRectWithCropRectView(_ cropRectView: CropRectView) -> CGRect {
        var cropRect = cropRectView.frame

        let rect = convert(cropRect, to: scrollView)
        if rect.minX < zoomingView!.frame.minX {
            cropRect.origin.x = scrollView.convert(zoomingView!.frame, to: self).minX
            let cappedWidth = rect.maxX
            let height = cropRect.size.height
            cropRect.size = CGSize(width: cappedWidth, height: height)
        }

        if rect.minY < zoomingView!.frame.minY {
            cropRect.origin.y = scrollView.convert(zoomingView!.frame, to: self).minY
            let cappedHeight = rect.maxY
            let width = cropRect.size.width
            cropRect.size = CGSize(width: width, height: cappedHeight)
        }

        if rect.maxX > zoomingView!.frame.maxX {
            let cappedWidth = scrollView.convert(zoomingView!.frame, to: self).maxX - cropRect.minX
            let height = cropRect.size.height
            cropRect.size = CGSize(width: cappedWidth, height: height)
        }

        if rect.maxY > zoomingView!.frame.maxY {
            let cappedHeight = scrollView.convert(zoomingView!.frame, to: self).maxY - cropRect.minY
            let width = cropRect.size.width
            cropRect.size = CGSize(width: width, height: cappedHeight)
        }

        return cropRect
    }
}

// MARK: - ScrollView delegate methods
extension CropView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomingView
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let contentOffset = scrollView.contentOffset
        targetContentOffset.pointee = contentOffset
    }
}

// MARK: - ScrollView delegate methods
extension CropView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - CropRectViewDelegate delegate methods
extension CropView: CropRectViewDelegate {
    func cropRectViewDidBeginEditing(_ view: CropRectView) {
        resizing = true
    }
    
    func cropRectViewDidChange(_ view: CropRectView) {
        let cropRect = cappedCropRectInImageRectWithCropRectView(view)
        layoutCropRectViewWithCropRect(cropRect)
    }
    
    func cropRectViewDidEndEditing(_ view: CropRectView) {
        resizing = false
        zoomToCropRect(cropRectView.frame)
    }
}
