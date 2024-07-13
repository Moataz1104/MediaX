//
//  PostDetailView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 12/07/2024.
//

import UIKit
import Hero
import RxSwift
import RxCocoa

class PostDetailView: UIViewController {
    
    
    //    MARK: - Attributes
    @IBOutlet weak var tableView: UITableView!
    
    let posts:[PostModel]
    let postVM:PostsViewModel
    let indexPath:IndexPath
    
    //    MARK: - View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true

        self.hero.isEnabled = true

        setUpTableView()
        registerCells()
    }
    
    init( posts: [PostModel],postVM : PostsViewModel,indexPath:IndexPath ) {
        self.posts = posts
        self.postVM = postVM
        self.indexPath = indexPath
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    MARK: - Actions
    
        
    @IBAction func panViewGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: nil)
        let progress = translation.y / 2 / view.bounds.height
        switch sender.state {
        case .began:
            hero.dismissViewController()
        case .changed:
            Hero.shared.update(progress)
            let currentPosition = CGPoint(x: translation.x + view.center.x, y: translation.y + view.center.y)
            Hero.shared.apply(modifiers: [.position(currentPosition)], to: view)

        default:
            Hero.shared.finish()
        }

    }
    
    
    

    
//    MARK: - Privates
    private func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.scrollToRow(at: IndexPath(row: indexPath.row, section: 0), at: .top, animated: true)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

    }
    private func registerCells(){
        tableView.register(UINib(nibName: PostTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: PostTableViewCell.identifier)
        }


}

extension PostDetailView:UITableViewDelegate,UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
        cell.viewModel = postVM
        cell.post = posts[indexPath.row]
        cell.configureCell(with: posts[indexPath.row], accessToken: "")
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 630
    }
    
}





