//
//  CropViewController.swift
//  SampleImageEditor
//
//  Created by ycsong on 2021/11/09.
//

import UIKit

protocol CropViewControllerDelegate {
    func cropViewController(didFinishCroppingImage image: UIImage?)
    func cropViewControllerDidCancel()
}

class CropViewController: UIViewController {
    
    private var image: UIImage?
    private var cropView: CropView!
    private var delegate: CropViewControllerDelegate?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(delegate vc: CropViewControllerDelegate, image: UIImage, style: UIModalPresentationStyle = .fullScreen) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = vc
        self.image = image
        self.modalPresentationStyle = style
    }
    
    //MARK: - UINavagationBar
    func generateNavBar() {
        let navBar = UINavigationBar()
        self.view.addSubview(navBar)
        
        navBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: navBar,
                               attribute: NSLayoutConstraint.Attribute.top,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: view.layoutMarginsGuide,
                               attribute: NSLayoutConstraint.Attribute.top,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: navBar,
                               attribute: NSLayoutConstraint.Attribute.width,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: view,
                               attribute: NSLayoutConstraint.Attribute.width,
                               multiplier: 1,
                               constant: 0),
        ])
        
        let navItem = UINavigationItem(title: "이미지 편집기")
        navItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(CropViewController.cancel(_:)))
        navItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CropViewController.done(_:)))
        navBar.setItems([navItem], animated: false)
    }
    
    //MARK: - UIToobar
    func getnerateToolBar() {
        let toolBar = UIToolbar()
        self.view.addSubview(toolBar)

        toolBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: toolBar,
                               attribute: NSLayoutConstraint.Attribute.bottom,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: view.layoutMarginsGuide,
                               attribute: NSLayoutConstraint.Attribute.bottom,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: toolBar,
                               attribute: NSLayoutConstraint.Attribute.width,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: view,
                               attribute: NSLayoutConstraint.Attribute.width,
                               multiplier: 1,
                               constant: 0),
        ])
        
        let crop = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(crop))
        let rotate = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(rotate))
        let fixeibleSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [crop, fixeibleSpacer, rotate]
    }
    
    override func loadView() {
        let contentView: UIView = {
            let v = UIView()
//            v.autoresizingMask = .flexibleWidth
//            v.backgroundColor = UIColor.black
            return v
        }()

        self.view = contentView
        self.cropView = CropView(frame: contentView.bounds)
        contentView.addSubview(cropView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cropView.image = image
        self.generateNavBar()
        self.getnerateToolBar()
    }
    
    @objc func crop(_ sender: UIBarButtonItem) {
        self.cropView.cropRectView.isHidden = !self.cropView.cropRectView.isHidden
    }
    
    @objc func rotate(_ sender: UIBarButtonItem) {
        self.cropView.rotationAngle = .pi / 2
    }
    
    @objc func cancel(_ sender: UIBarButtonItem) {
        self.delegate?.cropViewControllerDidCancel()
        self.dismiss(animated: true, completion: nil)
        cropView.cropRectView.isHidden = true
    }
    
    @objc func done(_ sender: UIBarButtonItem) {
        self.delegate?.cropViewController(didFinishCroppingImage: cropView.croppedImage)
        self.dismiss(animated: true, completion: nil)
    }
}

