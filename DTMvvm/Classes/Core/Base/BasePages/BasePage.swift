//
//  BasePage.swift
//  Test2
//
//  Created by toandk on 12/26/19.
//  Copyright © 2019 toandk. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import PureLayout

open class BasePage: UIViewController {
    
    public var disposeBag: DisposeBag? = DisposeBag()
    public var _viewModel: IModelType?
    
    
    public private(set) var backButton: UIBarButtonItem?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public init(viewModel: IModelType? = nil) {
        self._viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        initialize()
        DispatchQueue.main.async {
            self.viewModelChanged()
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent {
            destroy()
        }
    }
    
    /**
     Subclasses override this method to initialize UIs.
     
     This method is called in `viewDidLoad`. So try not to use `viewModel` property if you are
     not sure about it
     */
    open func initialize() {}
    
    /**
     Subclasses override this method to create data binding between view and viewModel.
     
     This method always happens, so subclasses should check if viewModel is nil or not. For example:
     ```
     guard let viewModel = viewModel else { return }
     ```
     */
    open func bindViewAndViewModel() {}
    
    /**
     Subclasses override this method to remove all things related to `DisposeBag`.
     */
    open func destroy() {
        disposeBag = DisposeBag()
        _viewModel?.destroy()
    }
    
    private func viewModelChanged() {
        bindViewAndViewModel()
        (_viewModel as? IReactable)?.reactIfNeeded()
    }
}
