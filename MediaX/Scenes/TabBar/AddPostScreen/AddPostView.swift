//
//  AddPostView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 01/07/2024.
//

import UIKit
import Photos

protocol addPostDelegate:AnyObject{
    func didDismissPhotoLibrary()
}

class AddPostView: UIViewController {

    
    weak var delegate : addPostDelegate?
    
    @IBOutlet weak var newPostImage: UIImageView!
    @IBOutlet weak var newPostContent: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextView()
        newPostContent.layer.cornerRadius = 40
        newPostImage.layer.cornerRadius = 40
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkPhotoLibraryPermission()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetView()
    }
    
    @IBAction func viewTapGesture(_ sender: Any) {
        view.endEditing(true)
    }
    
    
    private func setUpTextView(){
        newPostContent.delegate = self
        newPostContent.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        newPostContent.text = "Write a caption..."
        newPostContent.textColor = UIColor.lightGray
        
    }
    
    private func resetView(){
        newPostImage.image = UIImage(systemName: "square.and.arrow.up")
        newPostContent.text = "Write a caption..."
        newPostContent.textColor = UIColor.lightGray
    }
    
    

    
}


extension AddPostView :UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            openPhotoLibrary()
            openPhotoLibrary()
        case .denied, .restricted:
            
            showPermissionDeniedAlert()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
                if newStatus == .authorized {
                    DispatchQueue.main.async {
                        self?.openPhotoLibrary()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showPermissionDeniedAlert()
                    }
                }
            }
        default:
            break
        }
    }
    
    func openPhotoLibrary() {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
//            imagePicker.modalPresentationStyle = .fullScreen
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            
            let alert = UIAlertController(title: "Error", message: "Photo library is not available.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showPermissionDeniedAlert() {
        let alert = UIAlertController(title: "Permission Denied", message: "Please allow photo library access in settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            print("Selected image: \(selectedImage)")
            newPostImage.image = selectedImage
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        delegate?.didDismissPhotoLibrary()
    }

}

// MARK: - Text View Delegat
extension AddPostView:UITextViewDelegate{

    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "Write a caption..." || textView.text == ""{
            UIView.animate(withDuration: 0.3) {[weak self] in
                self?.textViewisEmpty()
            }
        }else{
            UIView.animate(withDuration: 0.3) {[weak self] in
                self?.textViewNotEmpty()
            }

        }

    }
    
    

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write a caption..." {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        
        if textView.text == "Write a caption..." || textView.text == ""{
            UIView.animate(withDuration: 0.3) {[weak self] in

                self?.textViewisEmpty()
            }
        }else{
            UIView.animate(withDuration: 0.3) {[weak self] in

                self?.textViewNotEmpty()
                
            }

        }
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write a caption..."
            textView.textColor = UIColor.lightGray
        }
        if textView.text == "Write a caption..." || textView.text == ""{
            UIView.animate(withDuration: 0.3) {[weak self] in
                self?.textViewisEmpty()
            }
        }else{
            UIView.animate(withDuration: 0.3) {[weak self] in
                self?.textViewNotEmpty()
            }

        }

    }
    
    private func textViewisEmpty(){
    }
    private func textViewNotEmpty(){
    }


    

}

