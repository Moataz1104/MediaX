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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        setUpTableView()
    }
    
    
    private func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: GeneralUserTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: GeneralUserTableViewCell.identifier)
    }



}

extension GeneralUsersView:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}
