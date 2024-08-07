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
    let commentViewModel:CommentsViewModel
    let post:PostModel
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: PostTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: PostTableViewCell.identifier)
        
        tableView.register(UINib(nibName: CommentTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: CommentTableViewCell.identifier)

    }
    init(postVM:PostsViewModel,commentVM:CommentsViewModel, post: PostModel) {
        self.post = post
        self.postViewModel = postVM
        self.commentViewModel = commentVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SinglePostView:UITableViewDelegate , UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            return post.comments?.count ?? 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
            
            cell.viewModel = postViewModel
            cell.post = post
            cell.configureCell(with: post)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as! CommentTableViewCell
            
            return cell
        }
    }
}
