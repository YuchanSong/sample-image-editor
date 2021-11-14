//
//  Dialog.swift
//  SampleImageEditor
//
//  Created by ycsong on 2021/11/14.
//

import UIKit

class Utils {
    class func alert(vc: UIViewController, _ title: String = "", msg: String, _ btnTitle: String = "OK", _ completion: ((UIAlertAction) -> ())? = nil){
          let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
          let action = UIAlertAction(title: btnTitle, style: .default, handler: completion)
          alert.addAction(action)
          vc.present(alert, animated: true, completion: nil)
    }
}

