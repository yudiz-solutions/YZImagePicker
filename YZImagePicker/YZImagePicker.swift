//
//  ImagePicker.swift
//  ImagePicker
//
//  Created by Yudiz Solutions Ltd on 07/11/23.
//

import UIKit
import AVKit
import Photos

class YZImagePicker: NSObject {
    
    fileprivate var pickerController: UIImagePickerController
    fileprivate var presentationController: UIViewController
    fileprivate var imageHandler: ((UIImage) -> Void)?
    fileprivate var allowEditing: Bool = false
    
    init(presentationController: UIViewController) {
        self.pickerController = UIImagePickerController()
        self.presentationController = presentationController
        super.init()
        self.pickerController.delegate = self
    }
}

//MARK: - Public Method
extension YZImagePicker {
    
    func pick(type: UIImagePickerController.SourceType,
              allowEditing: Bool = false,
              handler: @escaping (UIImage) -> Void) {
        imageHandler = handler
        self.allowEditing = allowEditing
        
        switch type {
        case .photoLibrary, .savedPhotosAlbum:
            self.openLibrary()
        case .camera:
            self.openCamera()
        @unknown default:
            break
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension YZImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[allowEditing ? .editedImage : .originalImage] as? UIImage {
            imageHandler?(selectedImage)
        }
        presentationController.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        presentationController.dismiss(animated: true, completion: nil)
    }
}

//MARK: - Camera & Library
extension YZImagePicker {
    
    fileprivate func openCamera() {
        cameraAccess { (status, isGranted) in
            if isGranted {
                DispatchQueue.main.async {
                    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                        self.pickImage(from: .camera)
                    }
                }
            }
        }
    }
    
    fileprivate func openLibrary() {
        photoLibraryAccess { (status, isGranted) in
            if isGranted {
                DispatchQueue.main.async {
                    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                        self.pickImage(from: .photoLibrary)
                    }
                }
            }
        }
    }
    
    fileprivate func pickImage(from source: UIImagePickerController.SourceType) {
        pickerController.sourceType = source
        pickerController.allowsEditing = allowEditing
        presentationController.present(pickerController, animated: true, completion: nil)
    }
}

//MARK: - Permissions
extension YZImagePicker {
    
    typealias PermissionStatus = (_ status: Int, _ isGranted: Bool) -> ()
    
    fileprivate func cameraAccess(permissionWithStatus block: @escaping PermissionStatus) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .authorized:
                block(AVAuthorizationStatus.authorized.rawValue, true)
            case .denied, .restricted:
                block(AVAuthorizationStatus.denied.rawValue, false)
                showAccessPopup(type: .camera)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                    DispatchQueue.main.async {
                        if granted {
                            block(AVAuthorizationStatus.authorized.rawValue, granted)
                        } else {
                            self.showAccessPopup(type: .camera)
                            block(AVAuthorizationStatus.denied.rawValue, granted)
                        }
                    }
                })
            @unknown default:
                break
            }
        } else {
            showAccessPopup(type: .camera)
            block(AVAuthorizationStatus.restricted.rawValue, false)
        }
    }
    
    fileprivate func showAccessPopup(type: UIImagePickerController.SourceType) {
        var title: String = ""
        var msg: String = ""
        
        switch type {
        case .photoLibrary, .savedPhotosAlbum:
            title = "No photos access"
            msg = "Please go to settings and switch on your photos."
        case .camera:
            title = "No camera access"
            msg = "Please go to settings and switch on your Camera."
        @unknown default:
            break
        }
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),completionHandler: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.presentationController.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func photoLibraryAccess(block: @escaping PermissionStatus) {
        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            block(status.rawValue, true)
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (perStatus) in
                if perStatus == PHAuthorizationStatus.authorized {
                    block(perStatus.rawValue, true)
                } else {
                    self.showAccessPopup(type: .photoLibrary)
                    block(perStatus.rawValue, false)
                }
            }
        } else {
            self.showAccessPopup(type: .photoLibrary)
            block(status.rawValue, false)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
