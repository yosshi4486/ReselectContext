//
//  UITableView+IndexPath.swift
//  ReselectContext
//
//  Created by seijin4486 on 2020/11/07.
//

import UIKit

extension UITableView {

    /// The last index path of table view.
    internal var lastIndexPath: IndexPath? {

        let lastSection = self.numberOfSections - 1

        guard lastSection >= 0 else { return nil }

        let lastRow = numberOfRows(inSection: lastSection) - 1

        guard lastRow >= 0 else { return nil }

        return IndexPath(row: lastRow, section: lastSection)
    }

}
