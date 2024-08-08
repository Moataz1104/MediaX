//
//  NotificationView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 23/06/2024.
//

import UIKit
import RxSwift
import RxCocoa

class NotificationView: UIViewController {
    
//    MARK: - Attributes
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag:DisposeBag
    let viewModel:NotificationViewModel
    
    var refreshControl = UIRefreshControl()
    
//    MARK: - ViewController life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        refreshControl.tintColor = UIColor.main
        
        refreshCollectionView()
        setUpTableView()
        reloadTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getAllNotificationsRelay.accept(())
    }
    
    init( disposeBag: DisposeBag, viewModel: NotificationViewModel) {
        self.disposeBag = disposeBag
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    MARK: - Actions
    
    @objc func refreshData() {
        DispatchQueue.main.async{[weak self] in
            self?.refreshControl.beginRefreshing()
            self?.viewModel.getAllNotificationsRelay.accept(())
            self?.refreshControl.endRefreshing()
        }
    }
    @objc func cellTapAction(_ sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        if let notifications = viewModel.notifications{
            if let postId = notifications[indexPath.row].postId,let notifiId = notifications[indexPath.row].id{
                viewModel.getPostNotiRelay.accept(("\(postId)","\(notifiId)"))
            }else if let userId = notifications[indexPath.row].fromUserId,let notifiId = notifications[indexPath.row].id{
                viewModel.getProfileNotiRelay.accept(("\(userId)","\(notifiId)"))
            }
        }
    }


//    MARK: - Privates
    private func refreshCollectionView(){
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
    }
    private func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: NotificationTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: NotificationTableViewCell.identifier)
        
    }
    
    private func reloadTableView(){
        viewModel.reloadTableClosure = {[weak self] in
            self?.tableView.reloadData()
        }
    }

}


extension NotificationView : UITableViewDelegate , UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.notifications?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as! NotificationTableViewCell
        if let notifications = viewModel.notifications{
            cell.configureCell(with: notifications[indexPath.row])
        }
        
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
