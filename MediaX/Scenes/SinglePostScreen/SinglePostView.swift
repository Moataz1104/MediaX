//
//  SinglePostView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 07/08/2024.
//

import UIKit

class SinglePostView: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    let postViewModel:PostsViewModel
    let post:PostModel
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupTableView()
    }
    init(postVM:PostsViewModel, post: PostModel) {
        self.post = post
        self.postViewModel = postVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self

        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.isScrollEnabled = false
        tableView.register(UINib(nibName: PostTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: PostTableViewCell.identifier)

    }

}

extension SinglePostView:UITableViewDelegate , UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
        
        cell.viewModel = postViewModel
        cell.post = post
        cell.indexPath = indexPath
        cell.configureCell(with: post)
        
        return cell

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        630
    }

}
