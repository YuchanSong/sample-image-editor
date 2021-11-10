//
//  ViewController.swift
//  SampleImageEditor
//
//  Created by ycsong on 2021/11/09.
//

import UIKit

class ViewController: UIViewController {
    
    private let picker = UIImagePickerController()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func getImageAction(_ sender: Any) {
        self.openLibrary()
    }
    
    @IBAction func cropAction(_ sender: Any) {
        if let i = self.imageView.image {
            let controller = CropViewController(delegate: self, image: i)
            self.present(controller, animated: true, completion: nil)
        } else {
            // 이미지가 업서여..
        }
    }
    
    @IBAction func flipAction(_ sender: Any) {
        self.imageView.transform = imageView.transform.rotated(by: CGFloat(Double.pi / 4)) //90 degree
    }
    
    func openLibrary() {
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.modalPresentationStyle = .fullScreen
        self.present(picker, animated: true, completion: nil)
    }
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = image
        }
        
        self.dismiss(animated: false, completion: {
            if let _ = self.imageView.image {
                DispatchQueue.main.async {
                    self.toolbar.isHidden ? self.toolbar.isHidden = false : nil
                }
            }
        })
    }
}

extension UIImage {
    func rotatedImageWithTransform(_ rotation: CGAffineTransform, croppedToRect rect: CGRect) -> UIImage {
        let rotatedImage = rotatedImageWithTransform(rotation)
        
        let scale = rotatedImage.scale
        let cropRect = rect.applying(CGAffineTransform(scaleX: scale, y: scale))
        
        let croppedImage = rotatedImage.cgImage?.cropping(to: cropRect)
        let image = UIImage(cgImage: croppedImage!, scale: self.scale, orientation: rotatedImage.imageOrientation)
        return image
    }
    
    fileprivate func rotatedImageWithTransform(_ transform: CGAffineTransform) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, scale)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: size.width / 2.0, y: size.height / 2.0)
        context?.concatenate(transform)
        context?.translateBy(x: size.width / -2.0, y: size.height / -2.0)
        draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotatedImage!
    }
}

extension ViewController: CropViewControllerDelegate {
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage) {
        // TODO
    }
    
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect) {
        // TODO
    }
    
    func cropViewControllerDidCancel(_ controller: CropViewController) {
        // TODO
    }
}
