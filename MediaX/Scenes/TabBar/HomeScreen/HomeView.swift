//
//  HomeView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 23/06/2024.
//

import UIKit
import RxSwift
import RxCocoa


class HomeView: UIViewController {
    
//    MARK: - Attributes
    
    let disposeBag:DisposeBag
    let viewModel:HomeViewModel
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    

    
//    MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        registerCells()

        configUi()

    }
    init(disposeBag:DisposeBag,viewModel:HomeViewModel) {
        self.disposeBag = disposeBag
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

//    MARK: - privates
    
    private func configUi(){
        mainView.layer.cornerRadius = 50
        mainView.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMinXMaxYCorner]

    }
    
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self

        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

    }
    
    private func registerCells(){
        tableView.register(UINib(nibName: StoriesTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: StoriesTableViewCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NormalCell")

    }


}



extension HomeView : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 20
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: StoriesTableViewCell.identifier, for: indexPath) as! StoriesTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalCell", for: indexPath)
            cell.textLabel?.text = "Row \(indexPath.row)"
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 70
        } else {
            return UITableView.automaticDimension
        }
    }


    
}
