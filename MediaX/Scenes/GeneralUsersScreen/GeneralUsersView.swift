//
//  GeneralUsersView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 05/08/2024.
//

import UIKit

class GeneralUsersView: UIViewController {

//    MARK: - Attributes
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    let viewModel:GeneralUsersViewModel
    let screenTitle:String
    let isLikeScreen:Bool
    var isFollow:Bool?
    

    
//    MARK: - ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        titleLabel.text = screenTitle
        
        setUpTableView()
        reloadTableView()
    }
    
    init(viewModel:GeneralUsersViewModel,title:String,isLikeScreen : Bool = false){
        
        self.viewModel = viewModel
        self.screenTitle = title
        self.isLikeScreen = isLikeScreen
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    MARK: - Actions
    
    @objc func cellTapAction(_ sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        if isLikeScreen{
            viewModel.pushProfileScreen(id: "\(viewModel.users[indexPath.row].userId!)")
        }else{
            viewModel.pushProfileScreen(id: "\(viewModel.users[indexPath.row].id!)")
        }
    }

//    MARK: - Privates
    
    private func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: GeneralUserTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: GeneralUserTableViewCell.identifier)
    }

    private func reloadTableView(){
        viewModel.reloadTableViewClosure = {[weak self] in
            self?.tableView.reloadData()
        }
    }



}

extension GeneralUsersView:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GeneralUserTableViewCell.identifier, for: indexPath) as! GeneralUserTableViewCell
        cell.generalUsersViewModel = viewModel
        cell.user = viewModel.users[indexPath.row]
        cell.configureUser(user: viewModel.users[indexPath.row])
        print(viewModel.users)
        let cellTapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapAction(_:)))
        cell.addGestureRecognizer(cellTapGesture)
        cell.isUserInteractionEnabled = true

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
