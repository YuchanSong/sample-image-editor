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
    
    private var imageView: UIImageView!
    private var imageSize = CGSize(width: 1.0, height: 1.0)
    
    private var scrollView: UIScrollView!
    private var zoomingView: UIView!
    private let cropRectView = CropRectView()
    
    private var insetRect = CGRect.zero
    
    public var croppedImage: UIImage? {
        return image?.screenshot(view: self.scrollView)
    }
    
    public var cropRectIsHidden = false {
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
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        
        addSubview(scrollView)
        addSubview(cropRectView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if imageView == nil {
            insetRect = bounds.insetBy(dx: 0.0, dy: 0.0)
            refreshView()
        }
    }
    
    // MARK: - Refresh scrollView & zoomingView
    private func refreshView() {
        if self.imageView != nil { scrollView.subviews.forEach({ $0.removeFromSuperview() }) }
        let cropRect = AVMakeRect(aspectRatio: imageSize, insideRect: insetRect)
        
        cropRectView.frame = cropRect
        scrollView.frame = cropRect
        scrollView.contentSize = cropRect.size
        zoomingView = UIView(frame: scrollView.bounds)
        
        imageView = UIImageView(frame: zoomingView.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        
        scrollView.addSubview(zoomingView)
        zoomingView.addSubview(imageView)
    }
}

// MARK: - ScrollView delegate
extension CropView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomingView
    }
}
