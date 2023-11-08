//
//  ViewController.swift
//  YZImagePicker
//
//  Created by Yudiz Solutions Ltd on 07/11/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imgView: UIImageView!

    var yzImagePicker: YZImagePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yzImagePicker = YZImagePicker(presentationController: self)
    }
    
    @IBAction func btnSelectImage(_ sender: Any) {
        yzImagePicker.pick(type: .photoLibrary) { image in
            self.imgView.image = image
        }
    }
}

