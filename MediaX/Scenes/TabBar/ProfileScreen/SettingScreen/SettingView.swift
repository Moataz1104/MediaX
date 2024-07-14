//
//  SettingView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 14/07/2024.
//

import UIKit
import RxSwift
import RxCocoa

class SettingView: UIViewController {

    
//    MARK: - Attributes
    let disposeBag:DisposeBag
    let viewModel:SettingViewModel
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var backImageView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var updateButton: UIButton!
    
    
//    MARK: - ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        keyBoardWillAppear()
        keyBoardWillDisappear()
        configUi()
    }
    
    init(disposeBag: DisposeBag, viewModel: SettingViewModel) {
        self.disposeBag = disposeBag
        self.viewModel = viewModel
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
    

//    MARK: - Privates
    
    private func configUi(){
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
            scrollView.contentInset.bottom = keyBoardHeight
        }
    }
    
    @objc func keyBoardDisappear(){
        scrollView.contentInset = .zero
    }


}
