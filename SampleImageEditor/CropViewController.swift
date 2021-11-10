//
//  CropViewController.swift
//  SampleImageEditor
//
//  Created by ycsong on 2021/11/09.
//

import UIKit

protocol CropViewControllerDelegate {
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage)
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect)
    func cropViewControllerDidCancel(_ controller: CropViewController)
}

class CropViewController: UIViewController {
    private var delegate: CropViewControllerDelegate?
    fileprivate var cropView: CropView?
    
    open var image: UIImage? {
        didSet {
            cropView?.image = image
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(delegate vc: CropViewControllerDelegate, image: UIImage, style: UIModalPresentationStyle = .fullScreen) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = vc
        self.image = image
        self.modalPresentationStyle = style
    }
    
    open override func loadView() {
        let contentView: UIView = {
            let v = UIView()
            v.autoresizingMask = .flexibleWidth
            v.backgroundColor = UIColor.black
            return v
        }()
        
        view = contentView
        
        // Add CropView
        cropView = CropView(frame: contentView.bounds)
        contentView.addSubview(cropView!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.toolbar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(CropViewController.cancel(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CropViewController.done(_:)))
        
//        if self.toolbarItems == nil {
//            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//            let constrainButton = UIBarButtonItem(title: "Constrain", style: .plain, target: self, action: #selector(CropViewController.constrain(_:)))
//            toolbarItems = [flexibleSpace, constrainButton, flexibleSpace]
//        }
        self.navigationController?.isToolbarHidden = false
        
        cropView?.image = image
    }
    
    @objc func cancel(_ sender: UIBarButtonItem) {
        delegate?.cropViewControllerDidCancel(self)
    }
    
    @objc func done(_ sender: UIBarButtonItem) {
        if let image = cropView?.croppedImage {
            delegate?.cropViewController(self, didFinishCroppingImage: image)
            guard let rotation = cropView?.rotation else {
                return
            }
            guard let rect = cropView?.zoomedCropRect() else {
                return
            }
            delegate?.cropViewController(self, didFinishCroppingImage: image, transform: rotation, cropRect: rect)
        }
    }
}
