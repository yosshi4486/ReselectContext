//
//  ReselectContext.swift
//  ReselectContext
//
//  Created by seijin4486 on 2020/11/07.
//

import UIKit

/// A context for re-selecting tableview cell.
///
/// Reselection should care about two cases bellow:
/// 1. For changes in EditMode.
/// 2. For changes other than EditMode.
///
/// The class prepared several main APIs for them
/// 1. `setReselect(deletedIndexPaths:)` and `commit()`
/// 2. `reselect(deletedIndexPaths:)`
///
/// - Attention:
/// Main APIs should be called **AFTER** updating table view cells. In some cases, you might have to call them in `DispatchQueue.main.async`.
public final class ReselectContext<DataSource : TableDataSource> {

    // MARK: - Public Variables

    /// The tableView you are interested in.
    public unowned var tableView: UITableView


    /// The dataSource to fetch indexPath and item.
    public unowned var dataSource: DataSource


    /// The item for selected row is pending until `commit()`.
    ///
    /// UITableView clears it's selection when the editMode property becomes true and it ignores `selectRow` while editing.
    /// so, for re-selecting, pending and re-selecting in `setEditing(false)` are needed.
    public private(set) var pendingItemForSelectedRow: DataSource.Item? = nil


    // MARK: - Private Variables

    public var pendingIndexPathForSelectedRow: IndexPath? {
        return dataSource.indexPath(for: pendingItemForSelectedRow)
    }


    private var sourceItemWhetherDetailedPendingOrNil: DataSource.Item? {

        if let aPendingItemForSelectedRow = self.pendingItemForSelectedRow {
            return aPendingItemForSelectedRow
        }
        return dataSource.detailedItem
    }


    // MARK: - Public Initializers
    public init(tableView: UITableView, dataSource: DataSource) {
        self.tableView = tableView
        self.dataSource = dataSource
    }


    // MARK: - Public Methods

    /// Calculate indexPath and item for new selection, then store it to `pendingItemForSelectedRow` property.
    ///
    /// - Remark:
    /// The interface is prepared for EditMode.
    public func setReselect(deletedIndexPaths: [IndexPath]? = nil) {

        guard let sourceItem = sourceItemWhetherDetailedPendingOrNil else { return }

        // Move, insert, enter editMode or delete without containing selected row.
        if let newIndexPathForItem = dataSource.indexPath(for: sourceItem)  {
            pendingItemForSelectedRow = dataSource.item(for: newIndexPathForItem)
            return
        }

        // Delete with containing selected row.
        if let newIndexPathWhenDeleteSelectedRow = self.newIndexPathWhenDeleteSelectedRow(from: deletedIndexPaths) {
            pendingItemForSelectedRow = dataSource.item(for: newIndexPathWhenDeleteSelectedRow)
            return
        }

    }


    /// Calculate indexPath and item for new selection, then execute `commit()` immediately.
    ///
    /// The method ignores and refreshes a stored pending selection.
    ///
    /// - Remark:
    /// The interface is prepared except for EditMode.
    public func reselect(deletedIndexPaths: [IndexPath]? = nil) {
        refresh()
        setReselect(deletedIndexPaths: deletedIndexPaths)
        commit()
    }


    /// Commit a pending selection to tableview.
    ///
    /// You call the method in `override setEditing(_ editing: Bool, animated: Bool)`.
    public func commit() {

        if let newIndexPath = pendingIndexPathForSelectedRow {
            // `selectRow` doesn't call delete methods automatically, so I call them manually.
            _ = tableView.delegate?.tableView?(tableView, willSelectRowAt: newIndexPath)
            tableView.selectRow(at: newIndexPath, animated: true, scrollPosition: .bottom)
            tableView.delegate?.tableView?(tableView, didSelectRowAt: newIndexPath)
        }
        refresh()
    }

    /// Refresh a pending selection.
    public func refresh() {
        pendingItemForSelectedRow = nil
    }


    // MARK: - Private Methods
    
    private func newIndexPathWhenDeleteSelectedRow(from deletedIndexPaths: [IndexPath]?) -> IndexPath? {

        guard let firstDeletedIndexPath = deletedIndexPaths?.first, let lastIndexPath = tableView.lastIndexPath else {
            return nil
        }

        if firstDeletedIndexPath < lastIndexPath {
            return firstDeletedIndexPath
        } else {
            return lastIndexPath
        }
    }

}

