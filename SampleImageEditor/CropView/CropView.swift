//
//  CropView.swift
//  CropViewController
//
//  Created by ycsong on 2021/11/09.
//

import UIKit
import AVFoundation

class CropView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public var image: UIImage? {
        didSet {
            if let image = image {
                self.imageSize = image.size
            }
        }
    }
    
    private var imageView: UIView?
    private var imageSize = CGSize(width: 1.0, height: 1.0)
    
    private var scrollView: UIScrollView!
    private var zoomingView: UIView!
    private let cropRectView = CropRectView()
    private let margin: CGFloat = 44.0
    
    private var insetRect = CGRect.zero
    private var resizing = false
    
    public var croppedImage: UIImage? {
        return image?.processingImage(image, croppedRect())
    }
    
    public var cropRectIsHidden = true {
        didSet {
            DispatchQueue.main.async {
                self.cropRectView.isHidden = self.cropRectIsHidden
            }
        }
    }
    
    public var rotation: CGFloat = 0.0 {
        didSet {
            self.image = self.image?.rotate(radians: rotation)
            self.refreshView()
        }
    }

    private func initialize() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        scrollView = UIScrollView(frame: bounds)
        scrollView.delegate = self
        scrollView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        addSubview(scrollView)
        
        cropRectView.delegate = self
        cropRectView.isHidden = cropRectIsHidden
        addSubview(cropRectView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if imageView == nil {
            insetRect = bounds.insetBy(dx: margin, dy: margin)
            refreshView()
        }
        
        resizing ? nil : resizeCropRectView(scrollView.frame)
    }
    
    // MARK: - Refresh scrollView & zoomingView
    private func refreshView() {
        if self.imageView != nil { scrollView.subviews.forEach({ $0.removeFromSuperview() }) }
        let cropRect = AVMakeRect(aspectRatio: imageSize, insideRect: insetRect)
        
        scrollView.frame = cropRect
        scrollView.contentSize = cropRect.size
        
        zoomingView = UIView(frame: scrollView.bounds)
        scrollView.addSubview(zoomingView)
        
        let imageView = UIImageView(frame: zoomingView.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        zoomingView.addSubview(imageView)
        self.imageView = imageView
    }
    
    // MARK: - CropRectView 사이즈 조절
    private func resizeCropRectView(_ cropRect: CGRect) {
        cropRectView.frame = cropRect
    }
    
    // MARK: - CropView 위치로 ScrollView 사이즈 변경
    private func zoomCroppedRect(_ toRect: CGRect) {
        if scrollView.frame.equalTo(toRect) { return }

        let width = toRect.width
        let height = toRect.height
        let scale = min(insetRect.width / width, insetRect.height / height)

        let scaledWidth = width * scale
        let scaledHeight = height * scale
        let cropRect = CGRect(
            x: (bounds.width - scaledWidth) / 2.0,
            y: (bounds.height - scaledHeight) / 2.0,
            width: scaledWidth,
            height: scaledHeight)

        var zoomRect = convert(toRect, to: zoomingView)
        zoomRect.size.width = cropRect.width / (scrollView.zoomScale * scale)
        zoomRect.size.height = cropRect.height / (scrollView.zoomScale * scale)

        UIView.animate(withDuration: 0.25, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.scrollView.bounds = cropRect
            self.scrollView.zoom(to: zoomRect, animated: false)
            self.resizeCropRectView(cropRect)
        })
    }
    
    // MARK: - Cropped Image Rect 계산
    private func croppedRect() -> CGRect {
        let cropRect = convert(scrollView.frame, to: zoomingView)
        let ratio = AVMakeRect(aspectRatio: imageSize, insideRect: insetRect).width / imageSize.width

        return CGRect(
            x: cropRect.origin.x / ratio,
            y: cropRect.origin.y / ratio,
            width: cropRect.size.width / ratio,
            height: cropRect.size.height / ratio)
    }
}

// MARK: - ScrollView delegate
extension CropView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomingView
    }
}

// MARK: - CropRectViewDelegate delegate
extension CropView: CropRectViewDelegate {
    func cropRectViewDidBeginEditing(_ view: CropRectView) {
        resizing = true
    }
    
    func cropRectViewDidChange(_ view: CropRectView, rect: CGRect) {
        resizeCropRectView(rect)
    }
    
    func cropRectViewDidEndEditing(_ view: CropRectView) {
        resizing = false
        zoomCroppedRect(cropRectView.frame)
    }
}
