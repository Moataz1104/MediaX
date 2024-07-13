//
//  CommentsView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 03/07/2024.
//

import UIKit
import RxSwift
import RxCocoa


class CommentsView: UIViewController {
    
    //    MARK: - Attributes
    
    let viewModel:CommentsViewModel
    let disposeBag:DisposeBag
    let post:PostModel
    var commentsCellHeights: [IndexPath: CGFloat] = [:]

    
    
    @IBOutlet weak var upperView: UIView!
    
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var textViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var textViewBottomCons: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    
    
    //    MARK: - View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        tableView.dataSource = self
        tableView.delegate = self
        upperView.layer.cornerRadius = 3
        
        keyBoardWillAppear()
        keyBoardWillDisappear()
        setUpTextView()

        bindSendButton()
        bindTextView()
        
        registerCells()
        
        subscribeToAddCommentPublisher()

        reloadTableView()

    }
    
    
    init(viewModel: CommentsViewModel, disposeBag: DisposeBag,post:PostModel) {
        self.viewModel = viewModel
        self.disposeBag = disposeBag
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//    MARK: - Action
    
    
    @IBAction func viewTapGesture(_ sender: Any) {
        view.endEditing(true)
    }
    
//    MARK: - Binders
    func bindSendButton(){
        sendButton.rx.tap.bind(to: viewModel.sendButtonRelay)
            .disposed(by: disposeBag)
    }
    func bindTextView(){
        commentTextView.rx.text.orEmpty.bind(to: viewModel.contentRelay)
            .disposed(by: disposeBag)
    }
    
    private func subscribeToAddCommentPublisher(){
        viewModel.commentAddedPublisher
            .subscribe {[weak self] _ in
                self?.textViewisEmpty()
                self?.commentTextView.text = "Add Comment For \(self?.post.username ?? "")"
                self?.commentTextView.textColor = UIColor.lightGray
                self?.view.endEditing(true)

            }
            .disposed(by: disposeBag)

    }
    


    
    
    //    MARK: - Private functions
    
    private func setUpTextView(){
        commentTextView.delegate = self
        commentTextView.textContainerInset = UIEdgeInsets(top: commentTextView.frame.height/2 - 20, left: 8, bottom: 0, right: 40)
        commentTextView.textContainer.lineFragmentPadding = 10
        commentTextView.text = "Add Comment For \(post.username ?? "")"
        commentTextView.textColor = UIColor.lightGray

    }
    
    private func registerCells(){
        tableView.register(UINib(nibName: CommentTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: CommentTableViewCell.identifier)
    }
    
    
    
    private func keyBoardWillAppear() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func keyBoardWillDisappear() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyBoardAppear(notification: NSNotification) {
        if let keyBoardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyBoardHeight = keyBoardFrame.cgRectValue.height
            UIView.animate(withDuration: 0.3) {[weak self] in
                self?.textViewBottomCons.constant = keyBoardHeight
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyBoardDisappear(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.textViewBottomCons.constant = 0
            self?.view.layoutIfNeeded()
        }
    }
    
    private func textViewisEmpty(){
        sendButton.setImage(UIImage(named: "disableButton"), for: .normal)
        sendButton.isEnabled = false
    }
    private func textViewNotEmpty(){
        sendButton.setImage(UIImage(named: "enableButton"), for: .normal)
        sendButton.isEnabled = true
    }

    private func reloadTableView() {
        viewModel.reloadTableClosure = { [weak self] isAnimated , indexPath in
            guard let self = self else { return }
            
            if isAnimated{
                let range = NSRange(location: 0, length: self.tableView.numberOfSections)
                let sections = IndexSet(integersIn: Range(range) ?? 0..<0)
                self.tableView.reloadSections(sections, with: .fade)
                
            }else{
                if let indexPath = indexPath{
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                
            }
        }
    }
}


// MARK: - Table View delegate
extension CommentsView:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.comments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as! CommentTableViewCell
        cell.indexPath = indexPath
        cell.viewModel = viewModel
        cell.comment = viewModel.comments[indexPath.row]
        cell.delegate = self
        if let token = viewModel.accessToken{
            cell.configureCell(with: viewModel.comments[indexPath.row],token: token)
        }
            
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        commentsCellHeights[indexPath] ?? 90
    }
    
    
}


// MARK: - Text View Delegat
extension CommentsView:UITextViewDelegate{

    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "Add Comment For \(post.username ?? "")" || textView.text == ""{
            UIView.animate(withDuration: 0.3) {[weak self] in
                self?.textViewisEmpty()
            }
        }else{
            UIView.animate(withDuration: 0.3) {[weak self] in
                self?.textViewNotEmpty()
            }

        }

    }
    
    

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add Comment For \(post.username ?? "")" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        
        if textView.text == "Add Comment For \(post.username ?? "")" || textView.text == ""{
            UIView.animate(withDuration: 0.3) {[weak self] in

                self?.textViewisEmpty()
            }
        }else{
            UIView.animate(withDuration: 0.3) {[weak self] in

                self?.textViewNotEmpty()
                
            }

        }
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add Comment For \(post.username ?? "")"
            textView.textColor = UIColor.lightGray
        }
        if textView.text == "Add Comment For \(post.username ?? "")" || textView.text == ""{
            UIView.animate(withDuration: 0.3) {[weak self] in
                self?.textViewisEmpty()
            }
        }else{
            UIView.animate(withDuration: 0.3) {[weak self] in
                self?.textViewNotEmpty()
            }

        }

    }

    

}


// MARK: - Comment Cell Delegate
extension CommentsView : CommentCellDelegate{
    func commentCellHeightDidChange(_ height: CGFloat, at indexPath: IndexPath) {
        commentsCellHeights[indexPath] = height
        tableView.beginUpdates()
        tableView.endUpdates()
    }

}
