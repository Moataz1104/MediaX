//
//  SearchView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 23/06/2024.
//

import UIKit
import RxSwift
import RxCocoa

class SearchView: UIViewController {

//    MARK: - Attributes
    @IBOutlet weak var mainViewTopCons: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableViewBottomCons: NSLayoutConstraint!
    
    let viewModel:SearchViewModel
    let disposeBag:DisposeBag
    

//    MARK: - View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUi()
        tableView.delegate = self
        tableView.dataSource = self
        searchTextField.delegate = self
        registerCell()
        keyBoardWillAppear()
        keyBoardWillDisappear()
        
        searchTextField.rx.text.orEmpty
            .bind(to: viewModel.searchTextFieldRelay)
            .disposed(by: disposeBag)
    }

    init(viewModel: SearchViewModel, disposeBag: DisposeBag) {
        self.viewModel = viewModel
        self.disposeBag = disposeBag
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    MARK: - Privates
    private func configUi(){
        navigationController?.navigationBar.isHidden = true
        searchTextField.setAttributedPlaceholder(with: "Search...", image: "magnifyingglass")

        mainViewTopCons.constant = view.frame.height * 0.1
        mainView.layer.cornerRadius = 40
        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func registerCell(){
        tableView.register(UINib(nibName: SearchTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SearchTableViewCell.identifier)
    }
    
    
    
    
}



//MARK: - Table view delegate
extension SearchView:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        viewModel.users?.count ?? 0
        20
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as! SearchTableViewCell
        
        if let user = viewModel.users?[indexPath.row]{
            cell.configureUser(user:user )
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
}

//MARK: - Text field delegate
extension SearchView:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
}

//MARK: - Handle keyBoard

extension SearchView{
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
                self?.tableViewBottomCons.constant = keyBoardHeight
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyBoardDisappear(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.tableViewBottomCons.constant = 0
            self?.view.layoutIfNeeded()
        }
    }

    
    

}
