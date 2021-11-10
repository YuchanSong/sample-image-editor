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
    
    private func initPicker() {
        self.picker.delegate = self
        self.picker.sourceType = .photoLibrary
        self.picker.modalPresentationStyle = .fullScreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initPicker()
    }
    
    @IBAction func openLibrary(_ sender: Any) {
        self.present(picker, animated: true, completion: nil)
    }
}

//MARK: - UIImagePickerController Delegate
extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.dismiss(animated: false, completion: {
                let controller = CropViewController(delegate: self, image: image)
                self.navigationController?.pushViewController(controller, animated: true)
            })
        }
    }
}

//MARK: - CropViewController Delegate
extension ViewController: CropViewControllerDelegate {
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage) {
        self.imageView.image = image
    }
}
