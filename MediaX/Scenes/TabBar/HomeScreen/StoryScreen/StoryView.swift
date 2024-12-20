//
//  StoryView.swift
//  MediaX
//
//  Created by Moataz Mohamed on 17/07/2024.
//

import UIKit
import Hero
import RxSwift
import RxCocoa
class StoryView: UIViewController {

    
    
//    MARK: - Attributes
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var bluredImage: UIImageView!
    @IBOutlet weak var storyImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var upperStack: UIStackView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var viewsStack: UIStackView!
    @IBOutlet weak var numberOfViews: UILabel!
    
    
    var indexPath:IndexPath?
    var timer: Timer?
    var progress: Float = 0.0
    var isInProgress = true
    
    let storyDetails:StoryModel
    let viewModel:StoryViewModel
    
    var storyImageDisposable:Disposable?
    var bluredImageDisposable:Disposable?
    var userImageDisposable:Disposable?

    var stackGesture:UITapGestureRecognizer!
//    MARK: - View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        stackGesture = UITapGestureRecognizer(target: self, action: #selector(viewStackAction))
        setUpUi()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpBlureEffect()
    }
    
    init(storyDetails:StoryModel,viewModel:StoryViewModel){
        self.storyDetails = storyDetails
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
    }
    deinit{
        storyImageDisposable?.dispose() 
        userImageDisposable?.dispose()
        bluredImageDisposable?.dispose()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//        MARK: - Actions
    @IBAction func xButtonAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func longPressGesture(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            isInProgress = false
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.upperStack.alpha = 0
            }
        case .ended:
            isInProgress = true
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.upperStack.alpha = 1
            }
        default:
            break
        }
    }
    @objc func viewStackAction(){
        if let storyId = storyDetails.id{
            viewModel.getViewsRelay.accept("\(storyId)")
        }
        
    }
    @objc func updateProgress() {
        if isInProgress {
            progress += 0.5 / 600
            progressView.setProgress(progress, animated: true)
            
            if progress >= 1.0 {
                timer?.invalidate()
                timer = nil
                self.dismiss(animated: true)
            }
        }
    }


//    MARK: - Privates
    private func setUpBlureEffect(){
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(blurEffectView)
        
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: self.view.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        view.bringSubviewToFront(storyImage)
        view.bringSubviewToFront(upperStack )
        view.bringSubviewToFront(viewsStack )

    }

    private func startProgress() {
        progress = 0.0
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    private func setUpUi(){
        self.hero.isEnabled = true
        if let indexPath = indexPath{
            storyImage.heroID = "\(indexPath.row)"
        }
        viewsStack.isHidden = true
        userImage.layer.cornerRadius = userImage.frame.width / 2
        userImage.clipsToBounds = true
        

        progressView.progress = 0.0
        

        configureStory()
        
        viewsStack.addGestureRecognizer(stackGesture)
        viewsStack.isUserInteractionEnabled = true

    }
    
    private func configureStory(){
        DispatchQueue.main.async{[weak self] in
            self?.userName.text = self?.storyDetails.username
            self?.timeLabel.text = self?.storyDetails.timeAgo
            
            if self?.storyDetails.numberOfViews != nil{
                self?.viewsStack.isHidden = false
                self?.numberOfViews.text = "\(self?.storyDetails.numberOfViews ?? 0)"
            }else{
                self?.viewsStack.isHidden = true
            }
        }
        
        storyImage.loadImage(url: URL(string: storyDetails.storyImage!)!){[weak self]_ in
            self?.startProgress()
        }
        
        bluredImage.loadImage(url: URL(string: storyDetails.storyImage!)!)

        userImage.loadImage(url: URL(string: storyDetails.userImage!)!)

        
    }

}
