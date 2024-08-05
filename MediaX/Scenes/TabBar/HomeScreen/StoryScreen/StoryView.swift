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
    
    let storyDetails:StoryDetailsModel
    var storyImageDisposable:Disposable?
    var bluredImageDisposable:Disposable?
    var userImageDisposable:Disposable?

//    MARK: - View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        self.hero.isEnabled = true
        if let indexPath = indexPath{
            storyImage.heroID = "\(indexPath.row)"
        }

        userImage.layer.cornerRadius = userImage.frame.width / 2
        userImage.clipsToBounds = true
        

        progressView.progress = 0.0
        startProgress()

        configureStory()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpBlureEffect()
    }
    
    init(storyDetails:StoryDetailsModel){
        self.storyDetails = storyDetails
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
    
    private func configureStory(){
        DispatchQueue.main.async{[weak self] in
            self?.userName.text = self?.storyDetails.username
            self?.timeLabel.text = self?.storyDetails.timeAgo
            self?.numberOfViews.text = "\(self?.storyDetails.numberOfViews ?? 0)"
        }
        
        storyImageDisposable = storyImage.loadImage(url: URL(string: storyDetails.storyImage!)!, indicator: nil)
        
        bluredImageDisposable = bluredImage.loadImage(url: URL(string: storyDetails.storyImage!)!, indicator: nil)

        userImageDisposable = userImage.loadImage(url: URL(string: storyDetails.userImage!)!, indicator: nil)

        
    }

}
