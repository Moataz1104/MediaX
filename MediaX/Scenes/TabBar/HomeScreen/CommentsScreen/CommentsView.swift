//
//  CommentsView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 03/07/2024.
//

import UIKit
import RxSwift
import RxCocoa
class CommentsView: UIViewController {
    
    
    //    MARK: - Attributes
    
    let viewModel:CommentsViewModel
    let disposeBag:DisposeBag
    
    @IBOutlet weak var upperView: UIView!
    
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var textViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var textViewBottomCons: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    
    
    //    MARK: - View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        
        upperView.layer.cornerRadius = 3
        
        keyBoardWillAppear()
        keyBoardWillDisappear()
        setUpTextView()

        tableView.dataSource = self
        tableView.delegate = self
        

    }
    
    
    init(viewModel: CommentsViewModel, disposeBag: DisposeBag) {
        self.viewModel = viewModel
        self.disposeBag = disposeBag
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//    MARK: - Action
    
    
    @IBAction func viewTapGesture(_ sender: Any) {
        view.endEditing(true)
    }
    
    
    
    //    MARK: - Private functions
    
    private func setUpTextView(){
        commentTextView.delegate = self
        commentTextView.textContainerInset = UIEdgeInsets(top: commentTextView.frame.height/2 - 20, left: 8, bottom: 0, right: 40)
        commentTextView.textContainer.lineFragmentPadding = 10
        commentTextView.text = "Add Comment For {}"
        commentTextView.textColor = UIColor.lightGray

    }
    
    
    
    private func keyBoardWillAppear() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func keyBoardWillDisappear() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyBoardAppear(notification: NSNotification) {
        if let keyBoardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyBoardHeight = keyBoardFrame.cgRectValue.height
            UIView.animate(withDuration: 0.3) {[weak self] in
                self?.textViewBottomCons.constant = keyBoardHeight
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyBoardDisappear(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.textViewBottomCons.constant = 0
            self?.view.layoutIfNeeded()
        }
    }
    
}


extension CommentsView:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}


extension CommentsView:UITextViewDelegate{

    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "Add Comment For {}" || textView.text == ""{
            UIView.animate(withDuration: 0.3) {[weak self] in

                self?.sendButton.setImage(UIImage(named: "disableButton"), for: .normal)
                self?.sendButton.isEnabled = false
            }
        }else{
            UIView.animate(withDuration: 0.3) {[weak self] in

                self?.sendButton.setImage(UIImage(named: "enableButton"), for: .normal)

                self?.sendButton.isEnabled = true
            }

        }

    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add Comment For {}" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        
        if textView.text == "Add Comment For {}" || textView.text == ""{
            UIView.animate(withDuration: 0.3) {[weak self] in

                self?.sendButton.setImage(UIImage(named: "disableButton"), for: .normal)

                self?.sendButton.isEnabled = false
            }
        }else{
            UIView.animate(withDuration: 0.3) {[weak self] in

                self?.sendButton.setImage(UIImage(named: "enableButton"), for: .normal)

                self?.sendButton.isEnabled = true
            }

        }
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add Comment For {}"
            textView.textColor = UIColor.lightGray
        }
        if textView.text == "Add Comment For {}" || textView.text == ""{
            UIView.animate(withDuration: 0.3) {[weak self] in

                self?.sendButton.setImage(UIImage(named: "disableButton"), for: .normal)

                self?.sendButton.isEnabled = false
            }
        }else{
            UIView.animate(withDuration: 0.3) {[weak self] in

                self?.sendButton.setImage(UIImage(named: "enableButton"), for: .normal)

                self?.sendButton.isEnabled = true
            }

        }

    }

    

}


