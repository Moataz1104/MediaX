//
//  AddPostCoordinator.swift
//  MediaX
//
//  Created by Moataz Mohamed on 01/07/2024.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
class AddPostCoordinator:Coordinator{
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    weak var delegate:addPostDelegate?
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let disposeBag = DisposeBag()
        let viewModel = AddPostViewModel(coordinator: self, disposeBag: disposeBag)
        let vc = AddPostView(disposeBag: disposeBag, viewModel: viewModel)
        vc.delegate = delegate
        navigationController.pushViewController(vc, animated: true)
    }
    
    
}
