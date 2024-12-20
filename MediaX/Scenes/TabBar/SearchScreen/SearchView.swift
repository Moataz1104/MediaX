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
    let disposeBag = DisposeBag()
    

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
        
        bindTextField()
        reloadTableView()
        
        subscribeToErrorPublisher()
    }

    init(viewModel: SearchViewModel) {
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
    
    @objc func cellTapAction(_ sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        if let users = viewModel.recentUsers{
            if let userId = users[indexPath.row].id{
                viewModel.pushProfileScree(id: "\(userId)")
            }
        }else if let users = viewModel.users{
            if let userId = users[indexPath.row].id{
                viewModel.pushProfileScree(id: "\(userId)")
            }
        }

    }
    
//    MARK: - Subscribers
    
    private func subscribeToErrorPublisher() {
        viewModel.errorPublisher
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                guard let error = event.element else {
                    print("Error element is nil")
                    return
                }
                
                let vc: ErrorsAlertView
                if let networkingError = error as? NetworkingErrors {
                    vc = ErrorsAlertView(errorTitleString: networkingError.title, message: networkingError.localizedDescription)
                } else {
                    vc = ErrorsAlertView(errorTitleString: "Error", message: error.localizedDescription)
                }
                
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve

                self?.present(vc, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
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
        tableView.register(UINib(nibName: GeneralUserTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: GeneralUserTableViewCell.identifier)
    }
    
    private func reloadTableView(){
        viewModel.reloadTableViewClosure = {[weak self] in
            guard let self = self else{return}
            DispatchQueue.main.async{
                let range = NSRange(location: 0, length: self.tableView.numberOfSections)
                let sections = IndexSet(integersIn: Range(range) ?? 0..<0)
                self.tableView.reloadSections(sections, with: .fade)
            }
            
        }

    }
    
    private func bindTextField(){
        searchTextField.rx.text.orEmpty
            .bind(to: viewModel.searchTextFieldRelay)
            .disposed(by: disposeBag)
        

    }
    
    
    
}



//MARK: - Table view delegate
extension SearchView:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.recentUsers?.count ?? viewModel.users?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let users = viewModel.recentUsers{
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as! SearchTableViewCell
            cell.user = users[indexPath.row]
            cell.viewModel = viewModel
            cell.configureUser(user: users[indexPath.row])
            
            let cellTapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapAction(_:)))
            cell.addGestureRecognizer(cellTapGesture)
            cell.isUserInteractionEnabled = true

            return cell
            
        }else if let users = viewModel.users{
            let cell = tableView.dequeueReusableCell(withIdentifier: GeneralUserTableViewCell.identifier, for: indexPath) as! GeneralUserTableViewCell
                
            cell.searchViewModel = viewModel
            cell.user = users[indexPath.row]
            cell.configureUser(user: users[indexPath.row])
            
            let cellTapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapAction(_:))) // Use tap gesture because of the cell selection bug
            cell.addGestureRecognizer(cellTapGesture)
            cell.isUserInteractionEnabled = true

            return cell
        }
        
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
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
