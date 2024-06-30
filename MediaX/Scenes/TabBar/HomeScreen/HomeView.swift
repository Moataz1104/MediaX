//
//  HomeView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 23/06/2024.
//

import UIKit
import RxSwift
import RxCocoa


protocol HomeViewDelegate: AnyObject {
    func didScrollDown()
    func didScrollUp()
}



class HomeView: UIViewController {
    
//    MARK: - Attributes
    
    let disposeBag:DisposeBag
    let viewModel:HomeViewModel
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoStack: UIStackView!
    @IBOutlet weak var logoStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    weak var delegate : HomeViewDelegate?


    private var previousScrollOffset: CGFloat = 0.0
    private var isLogoStackHidden = false

//    MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        registerCells()
        
        

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
    
    
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self

        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.bounces = false 

    }
    
    private func registerCells(){
        tableView.register(UINib(nibName: StoriesTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: StoriesTableViewCell.identifier)
        tableView.register(UINib(nibName: PostTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: PostTableViewCell.identifier)

    }


}



extension HomeView : UITableViewDelegate , UITableViewDataSource,UIScrollViewDelegate{
    
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
            let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 90
        } else {
            return 630
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let offsetDifference = currentOffset - previousScrollOffset

        if offsetDifference > 0 && !isLogoStackHidden {
            hideLogoStack()
            delegate?.didScrollDown()
        } else if offsetDifference < 0 && isLogoStackHidden {
            showLogoStack()
            delegate?.didScrollUp()
        }

        previousScrollOffset = currentOffset
    }

    private func hideLogoStack() {
        UIView.animate(withDuration: 0.5) {
            self.logoStackHeightConstraint.constant = 0
            self.tableViewTopConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
        isLogoStackHidden = true
    }

    private func showLogoStack() {
        UIView.animate(withDuration: 0.5) {
            self.logoStackHeightConstraint.constant = 30
            self.tableViewTopConstraint.constant = 110
            self.view.layoutIfNeeded()
        }
        isLogoStackHidden = false
    }

        
}
