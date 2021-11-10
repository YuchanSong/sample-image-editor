//
//  CropViewController.swift
//  SampleImageEditor
//
//  Created by ycsong on 2021/11/09.
//

import UIKit

protocol CropViewControllerDelegate {
    func cropViewController(_ vc: CropViewController, didFinishCroppingImage image: UIImage)
    func cropViewControllerDidCancel(_ vc: CropViewController)
}

class CropViewController: UIViewController {
    private var delegate: CropViewControllerDelegate?
    private var cropView: CropView!
    
    private var image: UIImage?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(delegate vc: CropViewControllerDelegate, image: UIImage, style: UIModalPresentationStyle = .fullScreen) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = vc
        self.image = image
        self.modalPresentationStyle = style
    }
    
    override func loadView() {
        let contentView: UIView = {
            let v = UIView()
            v.autoresizingMask = .flexibleWidth
            v.backgroundColor = UIColor.black
            return v
        }()

        self.view = contentView
        self.cropView = CropView(frame: contentView.bounds)
        contentView.addSubview(cropView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(CropViewController.cancel(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CropViewController.done(_:)))
        
        self.cropView.image = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func cancel(_ sender: UIBarButtonItem) {
        delegate?.cropViewControllerDidCancel(self)
    }
    
    @objc func done(_ sender: UIBarButtonItem) {
        if let image = cropView.croppedImage {
            delegate?.cropViewController(self, didFinishCroppingImage: image)
        } else {
            print("img return error....")
        }
    }
}
