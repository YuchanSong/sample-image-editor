//
//  CropRectView.swift
//  SampleImageEditor
//
//  Created by ycsong on 2021/11/09.
//

import UIKit

protocol CropRectViewDelegate {
    func cropRectViewDidBeginEditing(_ view: CropRectView)
    func cropRectViewDidChange(_ view: CropRectView, rect: CGRect)
    func cropRectViewDidEndEditing(_ view: CropRectView)
}

class CropRectView: UIView {
    
    public var delegate: CropRectViewDelegate?
    
    private var borderImgView: UIImageView!
    private let topLeftCornerView = ResizeControl()
    private let topRightCornerView = ResizeControl()
    private let bottomLeftCornerView = ResizeControl()
    private let bottomRightCornerView = ResizeControl()
    
    private var initialRect = CGRect.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        backgroundColor = UIColor.clear
        contentMode = .redraw
        
        if let image = UIImage(named: "CropBorder") {
            borderImgView = UIImageView(frame: bounds.insetBy(dx: -2.0, dy: -2.0))
            borderImgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            borderImgView.image = image.resizableImage(withCapInsets: UIEdgeInsets(top: 23.0, left: 23.0, bottom: 23.0, right: 23.0))
            addSubview(borderImgView)
        }
        
        topLeftCornerView.delegate = self
        addSubview(topLeftCornerView)
        
        topRightCornerView.delegate = self
        addSubview(topRightCornerView)
        
        bottomLeftCornerView.delegate = self
        addSubview(bottomLeftCornerView)
        
        bottomRightCornerView.delegate = self
        addSubview(bottomRightCornerView)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview in subviews where subview is ResizeControl {
            if subview.frame.contains(point) {
                return subview
            }
        }
        return nil
    }
    
    // MARK: - Draw Grid
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let width = bounds.width
        let height = bounds.height
        
        for i in 1 ..< 3 {
            let borderPadding: CGFloat = 0.5
            UIColor.white.set()
            UIRectFill(CGRect(x: round(CGFloat(i) * width / 3.0), y: borderPadding, width: 1.0, height: round(height) - borderPadding * 2.0))
            UIRectFill(CGRect(x: borderPadding, y: round(CGFloat(i) * height / 3.0), width: round(width) - borderPadding * 2.0, height: 1.0))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topLeftCornerView.frame.origin = CGPoint(
            x: topLeftCornerView.bounds.width / -2.0,
            y: topLeftCornerView.bounds.height / -2.0)
        
        topRightCornerView.frame.origin = CGPoint(
            x: bounds.width - topRightCornerView.bounds.width - 2.0,
            y: topRightCornerView.bounds.height / -2.0)
        
        bottomLeftCornerView.frame.origin = CGPoint(
            x: bottomLeftCornerView.bounds.width / -2.0,
            y: bounds.height - bottomLeftCornerView.bounds.height / 2.0)
        
        bottomRightCornerView.frame.origin = CGPoint(
            x: bounds.width - bottomRightCornerView.bounds.width / 2.0,
            y: bounds.height - bottomRightCornerView.bounds.height / 2.0)
    }
    
    private func resizeResizeControlView(_ resizeControl: ResizeControl) -> CGRect {
        var rect = frame
        
        switch resizeControl {
        case topLeftCornerView:
            rect = CGRect(x: initialRect.minX + resizeControl.translation.x,
                          y: initialRect.minY + resizeControl.translation.y,
                          width: initialRect.width - resizeControl.translation.x,
                          height: initialRect.height - resizeControl.translation.y)
        case topRightCornerView:
            rect = CGRect(x: initialRect.minX,
                          y: initialRect.minY + resizeControl.translation.y,
                          width: initialRect.width + resizeControl.translation.x,
                          height: initialRect.height - resizeControl.translation.y)
        case bottomLeftCornerView:
            rect = CGRect(x: initialRect.minX + resizeControl.translation.x,
                          y: initialRect.minY,
                          width: initialRect.width - resizeControl.translation.x,
                          height: initialRect.height + resizeControl.translation.y)
        case bottomRightCornerView:
            rect = CGRect(x: initialRect.minX,
                          y: initialRect.minY,
                          width: initialRect.width + resizeControl.translation.x,
                          height: initialRect.height + resizeControl.translation.y)
        default: ()
        }
        
        let minWidth = topLeftCornerView.bounds.width + topRightCornerView.bounds.width
        if rect.width < minWidth {
            rect.origin.x = frame.maxX - minWidth
            rect.size.width = minWidth
        }
        
        let minHeight = topLeftCornerView.bounds.height + topRightCornerView.bounds.height
        if rect.height < minHeight {
            rect.origin.y = frame.maxY - minHeight
            rect.size.height = minHeight
        }
        
        return rect
    }
}

// MARK: - ResizeControl delegate methods
extension CropRectView: ResizeControlDelegate {
    func resizeControlDidBeginResizing(_ control: ResizeControl) {
        initialRect = frame
        delegate?.cropRectViewDidBeginEditing(self)
    }
    
    func resizeControlDidResize(_ control: ResizeControl) {
        delegate?.cropRectViewDidChange(self, rect: resizeResizeControlView(control))
    }
    
    func resizeControlDidEndResizing(_ control: ResizeControl) {
        delegate?.cropRectViewDidEndEditing(self)
    }
}
