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
    weak var delegate:AddPostDelegate?
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = AddPostViewModel(apiService: APIPosts(), coordinator: self)
        let vc = AddPostView( viewModel: viewModel)
        vc.delegate = delegate
        navigationController.pushViewController(vc, animated: true)
    }
    
    
}
