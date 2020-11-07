//
//  TableDataSource.swift
//  ReselectContext
//
//  Created by seijin4486 on 2020/11/07.
//

import UIKit

/// A data source for fetching table data.
public protocol TableDataSource : AnyObject {

    associatedtype Item : Equatable

    
    /// Fetch indexPath for the given item.
    func indexPath(for item: Item?) -> IndexPath?


    /// Fetch item for the given indexPath.
    func item(for indexPath: IndexPath?) -> Item?


    /// The item is detailed such as previewed at secondary pane.
    var detailedItem: Item? { get set }

}

