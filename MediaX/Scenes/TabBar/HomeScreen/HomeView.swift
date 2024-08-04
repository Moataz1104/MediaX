//
//  HomeView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 23/06/2024.
//

import UIKit
import RxSwift
import RxCocoa
import Hero

protocol HomeViewDelegate: AnyObject {
    func didScrollDown()
    func didScrollUp()
}



class HomeView: UIViewController {
    
//    MARK: - Attributes
    
    let disposeBag:DisposeBag
    let postsViewModel:PostsViewModel
    let storyViewModel:StoryViewModel
    
    private var hasReachedBottom = false
    private var size = 5
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoStack: UIStackView!
    @IBOutlet weak var logoStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    weak var delegate : HomeViewDelegate?

    

    private var previousScrollOffset: CGFloat = 0.0
    private var isLogoStackHidden = false

//    MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        indicator.isHidden = true
        indicator.stopAnimating()
        self.hero.isEnabled = true

        setupTableView()
        registerCells()
        
        reloadTableView()
        subscribeToIndicatorPublisher()
        subscribeToErrorPublisher()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postsViewModel.sizeReciver.accept(size)
        storyViewModel.getStoriesRelay.accept(())

    }
    init(disposeBag:DisposeBag,viewModel:PostsViewModel,storyViewModel:StoryViewModel) {
        self.disposeBag = disposeBag
        self.postsViewModel = viewModel
        self.storyViewModel = storyViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//    MARK: - Subscribers
    
    private func subscribeToErrorPublisher() {
        postsViewModel.errorPublisher
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                guard let error = event.element else {
                    print("Error element is nil")
                    return
                }
                let vc = ErrorsAlertView(nibName: "ErrorsAlertView", bundle: nil)
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve

                if let networkingError = error as? NetworkingErrors {
                    DispatchQueue.main.async {
                        vc.errorTitle.text = networkingError.title
                        vc.errorMessage.text = networkingError.localizedDescription
                    }
                } else {
                    DispatchQueue.main.async {
                        vc.errorMessage.text = error.localizedDescription
                    }
                }

                self?.present(vc, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }

    private func subscribeToIndicatorPublisher(){
        postsViewModel.indicatorPublisher
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] isAnimate in
                if isAnimate{
                    self?.indicator.isHidden = false
                    self?.indicator.startAnimating()
                }else{
                    self?.indicator.isHidden = true
                    self?.indicator.stopAnimating()
                }
            }
            .disposed(by: disposeBag)
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
    
    private func reloadTableView(){
        postsViewModel.reloadTableViewClosure = {[weak self] in
            self?.tableView.reloadData()
        }
        storyViewModel.reloadTableViewClosure = {[weak self] in
            self?.tableView.reloadData()
        }
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
            return postsViewModel.posts.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: StoriesTableViewCell.identifier, for: indexPath) as! StoriesTableViewCell
            
            cell.viewModel = storyViewModel
            cell.reloadData()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
            cell.viewModel = postsViewModel
            cell.post = postsViewModel.posts[indexPath.row]
            cell.configureCell(with: postsViewModel.posts[indexPath.row])
            cell.delegate = delegate
            cell.settingButton.isHidden = true
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
        let bottomOffset = scrollView.contentSize.height - scrollView.bounds.height
        
        if scrollView.contentOffset.y >= bottomOffset && !hasReachedBottom {
            hasReachedBottom = true
            size += 5
            postsViewModel.sizeReciver.accept(size)
            
        } else if scrollView.contentOffset.y < bottomOffset {
            hasReachedBottom = false
        }

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
        UIView.animate(withDuration: 0.5) {[weak self] in
            self?.logoStackHeightConstraint.constant = 0
            self?.tableViewTopConstraint.constant = -30
            self?.view.layoutIfNeeded()
        }
        isLogoStackHidden = true
    }

    private func showLogoStack() {
        UIView.animate(withDuration: 0.5) {[weak self] in
            self?.logoStackHeightConstraint.constant = 30
            self?.tableViewTopConstraint.constant = 50
            self?.view.layoutIfNeeded()
        }
        isLogoStackHidden = false
    }

        
}
