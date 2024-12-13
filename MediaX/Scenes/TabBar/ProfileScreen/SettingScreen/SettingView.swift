//
//  SettingView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 14/07/2024.
//

import UIKit
import RxSwift
import RxCocoa
import Photos

class SettingView: UIViewController {

    
//    MARK: - Attributes
    let disposeBag = DisposeBag()
    let viewModel:SettingViewModel
    let user :UserModel
    var userImageLoadDisposable : Disposable?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var backImageView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
//    MARK: - ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUi()
        configureUser()
        setUpImageGesture()
        resetUserInfoClosure()
        keyBoardWillAppear()
        keyBoardWillDisappear()
        
        bindUserNameTextField()
        bindPhoneNumberTextField()
        bindBioTextView()
        bindUpdateButton()
        subscribeToButtonHidden()
        dismissViewClosure()
        emitFirstUserImage()
        subscribeToIndicatorPublisher()

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        userImageLoadDisposable?.dispose()
    }
    init(viewModel: SettingViewModel,user:UserModel) {
        self.viewModel = viewModel
        self.user = user
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    MARK: - Actions
    @IBAction func backButtonAction(_ sender: Any) {
        DispatchQueue.main.async{[weak self] in
            self?.dismiss(animated: true)
        }
    }
    @IBAction func viewTapGesture(_ sender: Any) {
        view.endEditing(true)
    }
    
//    MARK: - Binding
    
    private func bindUserNameTextField(){
        userNameTextField.rx.text.orEmpty
            .bind(to: viewModel.userNameRelay)
            .disposed(by: disposeBag)
        viewModel.userNameRelay.accept(user.fullName ?? "")
    }
    
    private func bindPhoneNumberTextField(){
        phoneTextField.rx.text.orEmpty
            .bind(to: viewModel.phoneNumberRelay)
            .disposed(by: disposeBag)
        viewModel.phoneNumberRelay.accept(user.phoneNumber ?? "")


    }

    private func bindBioTextView(){
        bioTextView.rx.text.orEmpty
            .bind(to: viewModel.bioRelay)
            .disposed(by: disposeBag)
        viewModel.bioRelay.accept(user.bio ?? "")

    }

    private func bindUpdateButton(){
        updateButton.rx.tap
            .bind(to: viewModel.updateButtonRelay)
            .disposed(by: disposeBag)
    }


    private func subscribeToButtonHidden(){
        viewModel.isUpdateButtonHiddenPublisher
            .subscribe {[weak self] isHidden in
                self?.updateButton.isHidden = isHidden
            }
            .disposed(by: disposeBag)

    }
    private func subscribeToIndicatorPublisher(){
        viewModel.indicatorPublisher
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] isAnimate in
                if isAnimate{
                    self?.indicator.isHidden = false
                    self?.indicator.startAnimating()
                }else{
                    self?.indicator.isHidden = true
                    self?.indicator.stopAnimating()
                }
            }
            .disposed(by: disposeBag)
    }
//    MARK: - Privates
    
    private func configUi(){
        indicator.isHidden = true
        indicator.stopAnimating()
        userImage.layer.cornerRadius = userImage.frame.width / 2
        userImage.clipsToBounds = true
        
        backImageView.layer.cornerRadius = backImageView.bounds.width / 2
        backImageView.clipsToBounds = true
        
        userNameTextField.setAttributedPlaceholder(with: "Your New User Name", image: "personIcon")
        phoneTextField.setAttributedPlaceholder(with: "Your New Phone Number", image: "phone")

        bioTextView.textContainerInset = UIEdgeInsets(top:10, left: 8, bottom: 0, right: 0)
        bioTextView.layer.cornerRadius = 20
        bioTextView.textContainer.lineFragmentPadding = 10

        updateButton.layer.cornerRadius = 15

    }
    
    private func configureUser() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Configure user text fields and bio
            self.userNameTextField.text = self.user.fullName ?? ""
            self.phoneTextField.text = self.user.phoneNumber ?? ""
            self.bioTextView.text = self.user.bio ?? ""
            
            // Use Kingfisher to load and cache the image
            if let imageUrlString = self.user.image, let imageUrl = URL(string: imageUrlString) {
                self.userImage.kf.setImage(with: imageUrl, completionHandler: { [weak self] result in
                    switch result {
                    case .success(let value):
                        if let imageData = value.image.jpegData(compressionQuality: 0.99) {
                            self?.viewModel.imageDataPublisher.accept(imageData)
                        }
                    case .failure(let error):
                        print("Error loading image: \(error.localizedDescription)")
                    }
                })
            }
        }
    }

    private func resetUserInfoClosure(){
        viewModel.resetUserInfo = {[weak self] in
            self?.configureUser()
        }
    }
    
    
    private func dismissViewClosure(){
        viewModel.dismissView = {[weak self] in
            self?.dismiss(animated: true)
        }

    }
    private  func emitFirstUserImage(){
        if let imageData = userImage.image!.jpegData(compressionQuality: 0.99) {
            viewModel.imageDataPublisher.accept(imageData)
        }

    }
    
    private func setUpImageGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        userImage.addGestureRecognizer(tapGesture)
        userImage.isUserInteractionEnabled = true
    }

    @objc func handleImageTap(){
        checkPhotoLibraryPermission()
    }

}

//    MARK: - Handling KeyBoard

extension SettingView{
    
    private func keyBoardWillAppear(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    private func keyBoardWillDisappear(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyBoardAppear(notification : NSNotification){
        if let keyBoardFrame : NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
            let keyBoardHeight = keyBoardFrame.cgRectValue.height
            scrollView.contentInset.bottom = keyBoardHeight + 20
        }
    }
    
    @objc func keyBoardDisappear(){
        scrollView.contentInset = .zero
    }


}


extension SettingView :UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
            userImage.image = selectedImage
            if let imageData = selectedImage.jpegData(compressionQuality: 0.99) {
                viewModel.imageDataPublisher.accept(imageData)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
