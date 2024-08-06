//
//  GeneralUsersView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 05/08/2024.
//

import UIKit

class GeneralUsersView: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    let viewModel:GeneralUsersViewModel
    let users : [UserModel]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        setUpTableView()
        viewModel.reloadTableViewClosure = {[weak self] in
            self?.tableView.reloadData()
        }
    }
    
    init(viewModel:GeneralUsersViewModel,users:[UserModel]){
        self.users = users
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: GeneralUserTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: GeneralUserTableViewCell.identifier)
    }

    @objc func cellTapAction(_ sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        viewModel.pushProfileScreen(id: "\(users[indexPath.row].id!)")
    }



}

extension GeneralUsersView:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GeneralUserTableViewCell.identifier, for: indexPath) as! GeneralUserTableViewCell
        cell.generalUsersViewModel = viewModel
        cell.user = users[indexPath.row]
        cell.configureUser(user: users[indexPath.row])
        
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
