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
    
    
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var textFieldBottomCons: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    //    MARK: - View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        keyBoardWillAppear()
        keyBoardWillDisappear()

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

    
    
    //    MARK: - Private functions
    private func keyBoardWillAppear() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func keyBoardWillDisappear() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyBoardAppear(notification: NSNotification) {
        if let keyBoardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyBoardHeight = keyBoardFrame.cgRectValue.height
            UIView.animate(withDuration: 0.3) {
                self.textFieldBottomCons.constant = -keyBoardHeight
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyBoardDisappear(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.textFieldBottomCons.constant = 0
            self.view.layoutIfNeeded()
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
