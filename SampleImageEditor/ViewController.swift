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
            self.dismiss(animated: false, completion: { [weak self] in
                guard let sself = self else { return }
                let cropVC = CropViewController(delegate: sself, image: image)
                sself.present(cropVC, animated: true, completion: nil)
            })
        }
    }
}

//MARK: - CropViewController Delegate
extension ViewController: CropViewControllerDelegate {
    func cropViewController(vc: CropViewController, didFinishCroppingImage image: UIImage?) {
        if let _ = image {
            vc.dismiss(animated: false, completion: { [weak self] in
                guard let sself = self else { return }
                DispatchQueue.main.async {
                    sself.imageView.image = image
                }
            })
        } else {
            print("이미지 처리에 실패하였습니다 :(")
        }
    }
    
    func cropViewControllerDidCancel(vc: CropViewController) {
        vc.dismiss(animated: false, completion: nil)
        print("user canceled")
    }
}
