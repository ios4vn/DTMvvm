//
//  BaseListPage.swift
//  Test2
//
//  Created by toandk on 12/26/19.
//  Copyright © 2019 toandk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

open class BaseListPage: BasePage {
    
    public var tableView: UITableView!
    public var dataSource: RxTableViewSectionedAnimatedDataSource<SectionList<NSObject>>?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        if tableView == nil {
            tableView = UITableView(frame: .zero, style: .plain)
            view.addSubview(tableView)
            DispatchQueue.main.async {
                self.bindViewAndViewModel()
            }
        }
        tableView.backgroundColor = .clear
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.backgroundView = nil
    }
    
    open override func initialize() {
        tableView.autoPinEdgesToSuperviewEdges(with: .zero)
    }
    
    open override func destroy() {
        super.destroy()
        tableView.removeFromSuperview()
    }
    
    /// Every time the viewModel changed, this method will be called again, so make sure to call super for ListPage to work
    open override func bindViewAndViewModel() {
        guard tableView != nil else { return }
        tableView.rx.itemSelected.asObservable().subscribe(onNext: onItemSelected) => disposeBag
        
        dataSource = RxTableViewSectionedAnimatedDataSource<SectionList<NSObject>>(
            configureCell: { dataSource, tableView, indexPath, item in
                if let cellViewModel = item as? IModelType {
                    let identifier = self.cellIdentifier(cellViewModel)
                    let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                    if let cell = cell as? IAnyView {
                        cell.anyViewModel = cellViewModel
                    }
                    (cellViewModel as? IIndexable)?.indexPath = indexPath
                    return cell
                }
                return UITableViewCell()
        })
        
        (_viewModel as? IListItemType)?.rxNSObjectSources
            .bind(to: tableView.rx.items(dataSource: dataSource!)) => disposeBag
    }
    
    private func onItemSelected(_ indexPath: IndexPath) {
        guard let viewModel = self._viewModel as? IListItemType,
            let cellViewModel = viewModel.getItem(at: indexPath)
            else { return }
        
        selectedItemDidChange(cellViewModel)
    }
    
    // MARK: - Abstract for subclasses
    
    /**
     Subclasses have to override this method to return correct cell identifier based `CVM` type.
     */
    open func cellIdentifier(_ cellViewModel: Any) -> String {
        fatalError("Subclasses have to implement this method.")
    }
    
    /**
     Subclasses override this method to handle cell pressed action.
     */
    open func selectedItemDidChange(_ cellViewModel: Any) { }
}

