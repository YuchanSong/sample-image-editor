//
//  CropRectView.swift
//  SampleImageEditor
//
//  Created by ycsong on 2021/11/09.
//

import UIKit

class CropRectView: UIView {
    
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
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview in subviews {
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
            UIRectFill(CGRect(x: round(CGFloat(i) * width / 3.0), y: borderPadding,
                              width: 1.0, height: round(height) - borderPadding * 2.0))
            
            UIRectFill(CGRect(x: borderPadding, y: round(CGFloat(i) * height / 3.0),
                              width: round(width) - borderPadding * 2.0, height: 1.0))
        }
    }
}
