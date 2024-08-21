//
//  AddPostView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 01/07/2024.
//

import UIKit
import Photos
import RxSwift
import RxCocoa

protocol AddPostDelegate:AnyObject{
    func didDismissPhotoLibrary()
}

class AddPostView: UIViewController {

//    MARK: - Attributes
    
    weak var delegate : AddPostDelegate?
    let viewModel : AddPostViewModel
    let disposeBag = DisposeBag()
    
    
    @IBOutlet weak var newPostImage: UIImageView!
    @IBOutlet weak var newPostContent: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
//    MARK: - View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUi()
        
        setUpTextView()
        setUpImageTapGesture()
        
        subscribeToIndicatorPublisher()
        subscribeToErrorPublisher()
        
        bindTextView()

        
        successClosure()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !indicator.isAnimating{
            DispatchQueue.main.async{[weak self] in
                self?.checkPhotoLibraryPermission()
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetView()
    }
    
    init(viewModel:AddPostViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//    MARK: - Actions
    @IBAction func viewTapGesture(_ sender: Any) {
        view.endEditing(true)
    }
    
    @objc func imageTapAction(){
        DispatchQueue.main.async{[weak self] in
            self?.checkPhotoLibraryPermission()
        }
    }
    @IBAction func postButtonAction(_ sender: Any) {
        viewModel.postButtonBinder.accept(())
    }
    
//    MARK: - Binings
    
    private func bindTextView(){
        newPostContent.rx.text.orEmpty.bind(to: viewModel.contentTextViewBinder)
            .disposed(by: disposeBag)

    }
    
    private func subscribeToIndicatorPublisher(){
        viewModel.indicatorPublisher
            .subscribe {[weak self] isAnimating in
                if isAnimating{
                    self?.indicator.isHidden = false
                    self?.indicator.startAnimating()
                    
                }else{
                    self?.indicator.isHidden = true
                    self?.indicator.stopAnimating()

                }
            }
            .disposed(by: disposeBag)

    }
    
    
    private func subscribeToErrorPublisher() {
        viewModel.errorPublisher
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                guard let error = event.element else {
                    print("Error element is nil")
                    return
                }
                let vc = ErrorsAlertView(nibName: "ErrorsAlertView", bundle: nil)
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve

                if let networkingError = error as? NetworkingErrors {
                    DispatchQueue.main.async {
                        vc.errorTitle.text = networkingError.title
                        vc.errorMessage.text = networkingError.localizedDescription
                    }
                } else {
                    DispatchQueue.main.async {
                        vc.errorMessage.text = error.localizedDescription
                    }
                }

                self?.present(vc, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }

    
    
//    MARK: - privates
    
    private func configureUi(){
        DispatchQueue.main.async{[weak self] in
            self?.checkPhotoLibraryPermission()
        }

        postButton.isHidden = true
        indicator.isHidden = true
        indicator.stopAnimating()

        
        newPostContent.layer.cornerRadius = 10
        newPostImage.layer.cornerRadius = 40
        postButton.layer.cornerRadius = postButton.bounds.height / 2

    }
    private func successClosure(){
        viewModel.successClosure = {[weak self] in
            self?.delegate?.didDismissPhotoLibrary()
        }

    }
    
    private func setUpImageTapGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapAction))
        
        newPostImage.addGestureRecognizer(tap)
        newPostImage.isUserInteractionEnabled = true
    }
    
    private func postButtonSetup(){
        if newPostImage.image == UIImage(systemName: "square.and.arrow.up.fill"){
            postButton.isHidden = true
        }else{
            postButton.isHidden = false
        }
    }


    private func setUpTextView(){
        newPostContent.delegate = self
        newPostContent.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        newPostContent.text = "Write a caption..."
        newPostContent.textColor = UIColor.lightGray
        
    }
    
    private func resetView(){
        newPostImage.image = UIImage(systemName: "square.and.arrow.up.fill")
        newPostContent.text = "Write a caption..."
        postButton.isHidden = true
        newPostContent.textColor = UIColor.lightGray
        viewModel.clearState()
    }
    
    

    
}


extension AddPostView :UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
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
            newPostImage.image = selectedImage
            if let imageData = selectedImage.jpegData(compressionQuality: 0.99) {
                viewModel.selectedImageData = imageData
            }
            postButtonSetup()
        }
        picker.dismiss(animated: true, completion: nil)
    }

    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        resetView()
        delegate?.didDismissPhotoLibrary()
    }

}

// MARK: - Text View Delegat
extension AddPostView:UITextViewDelegate{

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write a caption..." {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write a caption..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    

}

