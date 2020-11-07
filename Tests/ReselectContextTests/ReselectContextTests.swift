import XCTest
@testable import ReselectContext

final class ReselectContextTests: XCTestCase {

    final class StubDataSource: NSObject, UITableViewDataSource, TableDataSource {

        typealias Item = String

        var allData: [String] = ["apple", "butternut squash", "carrot", "date", "elderberry"]

        var detailedItem: String?

        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return allData.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            return cell
        }

        func item(for indexPath: IndexPath?) -> String? {

            guard let anIndexPath = indexPath else { return nil }

            return allData[anIndexPath.row]
        }

        func indexPath(for item: String?) -> IndexPath? {

            guard let anItem = item else { return nil }

            guard let index = allData.firstIndex(of: anItem) else { return nil }

            return IndexPath(row: index, section: 0)
        }

    }


    var tableView: UITableView!

    var dataSource: StubDataSource!

    var context: ReselectContext<StubDataSource>!

    override func setUpWithError() throws {
        tableView = .init()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.reloadData()

        dataSource = .init()
        tableView.dataSource = dataSource

        context = .init(tableView: tableView, dataSource: dataSource)
    }


    override func tearDownWithError() throws {
        tableView = nil
        dataSource = nil
        context = nil
    }


    func testMove() {

        dataSource.detailedItem = dataSource.allData[2]

        let deletedIndexPath = IndexPath(row: 2, section: 0)
        let insertedIndexPath = IndexPath(row: 4, section: 0)

        let testExpectation = expectation(description: "testMove")
        tableView.performBatchUpdates {

            dataSource.allData.swapAt(2, 4)

            tableView.deleteRows(at: [deletedIndexPath], with: .automatic)
            tableView.insertRows(at: [insertedIndexPath], with: .automatic)

        } completion: { [weak self](_) in

            self!.context.reselect(deletedIndexPaths: [deletedIndexPath])

            XCTAssertEqual(self!.dataSource.allData[self!.tableView.indexPathForSelectedRow!.row], "carrot")
            XCTAssertEqual(self!.tableView.indexPathForSelectedRow, insertedIndexPath)
            testExpectation.fulfill()
        }

        wait(for: [testExpectation], timeout: 1.0)
    }


    func testDelete() {
        dataSource.detailedItem = dataSource.allData[2]

        let deletedIndexPath = IndexPath(row: 2, section: 0)
        let expectedNewIndexPathForSelectedRow = IndexPath(row: 2, section: 0)

        let testExpectation = expectation(description: "testDelete")
        tableView.performBatchUpdates {

            dataSource.allData.remove(at: 2)

            tableView.deleteRows(at: [deletedIndexPath], with: .automatic)

        } completion: { [weak self](_) in

            self?.context.reselect(deletedIndexPaths: [deletedIndexPath])

            XCTAssertEqual(self!.dataSource.allData[self!.tableView.indexPathForSelectedRow!.row], "date")
            XCTAssertEqual(self?.tableView.indexPathForSelectedRow, expectedNewIndexPathForSelectedRow)
            testExpectation.fulfill()
        }

        wait(for: [testExpectation], timeout: 1.0)

    }


    func testDeleteLast() {
        dataSource.detailedItem = dataSource.allData.last

        let deletedIndexPath = IndexPath(row: 4, section: 0)
        let expectedNewIndexPathForSelectedRow = IndexPath(row: 3, section: 0)

        let testExpectation = expectation(description: "testDelete")
        tableView.performBatchUpdates {

            dataSource.allData.removeLast()

            tableView.deleteRows(at: [deletedIndexPath], with: .automatic)

        } completion: { [weak self](_) in

            self?.context.reselect(deletedIndexPaths: [deletedIndexPath])

            XCTAssertEqual(self!.dataSource.allData[self!.tableView.indexPathForSelectedRow!.row], "date")
            XCTAssertEqual(self?.tableView.indexPathForSelectedRow, expectedNewIndexPathForSelectedRow)
            testExpectation.fulfill()
        }

        wait(for: [testExpectation], timeout: 1.0)

    }

    func testMoveOnEdit() {
        dataSource.detailedItem = dataSource.allData[2]

        let deletedIndexPath = IndexPath(row: 2, section: 0)
        let insertedIndexPath = IndexPath(row: 4, section: 0)

        let testExpectation = expectation(description: "testMoveOnEdit")
        tableView.performBatchUpdates {

            dataSource.allData.swapAt(2, 4)

            tableView.deleteRows(at: [deletedIndexPath], with: .automatic)
            tableView.insertRows(at: [insertedIndexPath], with: .automatic)

        } completion: { [weak self](_) in

            self!.context.setReselect()
            XCTAssertNil(self!.tableView.indexPathForSelectedRow)

            self!.context.commit()
            XCTAssertEqual(self!.dataSource.allData[self!.tableView.indexPathForSelectedRow!.row], "carrot")
            XCTAssertEqual(self!.tableView.indexPathForSelectedRow, insertedIndexPath)
            testExpectation.fulfill()
        }

        wait(for: [testExpectation], timeout: 1.0)

    }


    func testInsertOnEdit() {
        dataSource.detailedItem = dataSource.allData[2]

        let insertedIndexPath = IndexPath(row: 2, section: 0)
        let expectedNewIndexPathForSelectedRow = IndexPath(row: 3, section: 0)

        let testExpectation = expectation(description: "testMoveOnEdit")
        tableView.performBatchUpdates {

            dataSource.allData.insert("Orange", at: 2)

            tableView.insertRows(at: [insertedIndexPath], with: .automatic)

        } completion: { [weak self](_) in

            self!.context.setReselect()
            XCTAssertNil(self!.tableView.indexPathForSelectedRow)

            self!.context.commit()
            XCTAssertEqual(self!.dataSource.allData[self!.tableView.indexPathForSelectedRow!.row], "carrot")
            XCTAssertEqual(self!.tableView.indexPathForSelectedRow, expectedNewIndexPathForSelectedRow)
            testExpectation.fulfill()
        }

        wait(for: [testExpectation], timeout: 1.0)
    }


    func testDeleteOnEdit() {
        dataSource.detailedItem = dataSource.allData[2]

        let deletedIndexPath = IndexPath(row: 2, section: 0)
        let expectedNewIndexPathForSelectedRow = IndexPath(row: 2, section: 0)

        let testExpectation = expectation(description: "testDelete")
        tableView.performBatchUpdates {

            dataSource.allData.remove(at: 2)

            tableView.deleteRows(at: [deletedIndexPath], with: .automatic)

        } completion: { [weak self](_) in

            self!.context.setReselect(deletedIndexPaths: [deletedIndexPath])
            XCTAssertNil(self!.tableView.indexPathForSelectedRow)

            self!.context.commit()
            XCTAssertEqual(self!.dataSource.allData[self!.tableView.indexPathForSelectedRow!.row], "date")
            XCTAssertEqual(self!.tableView.indexPathForSelectedRow, expectedNewIndexPathForSelectedRow)
            testExpectation.fulfill()
        }

        wait(for: [testExpectation], timeout: 1.0)

    }


    func testNothingOnEdit() {
        dataSource.detailedItem = dataSource.allData[2]

        let expectedNewIndexPathForSelectedRow = IndexPath(row: 2, section: 0)

        context.setReselect()
        XCTAssertNil(tableView.indexPathForSelectedRow)

        context.commit()
        XCTAssertEqual(dataSource.allData[tableView.indexPathForSelectedRow!.row], "carrot")
        XCTAssertEqual(tableView.indexPathForSelectedRow, expectedNewIndexPathForSelectedRow)
    }


    func testSequenceOnEdit() {

        // Delete→Move→Insert

        dataSource.detailedItem = dataSource.allData[2]

        XCTContext.runActivity(named: "Delete") { (_) in
            let deleteExpectation = expectation(description: "Delete")
            let deletedIndexPath = IndexPath(row: 2, section: 0)

            tableView.performBatchUpdates {
                dataSource.allData.remove(at: 2)
                tableView.deleteRows(at: [deletedIndexPath], with: .automatic)
            } completion: { [unowned self] (_) in
                self.context.setReselect(deletedIndexPaths: [deletedIndexPath])
                deleteExpectation.fulfill()
            }

            wait(for: [deleteExpectation], timeout: 1.0)

            XCTAssertEqual(context.pendingIndexPathForSelectedRow, IndexPath(row: 2, section: 0))
            XCTAssertEqual(context.pendingItemForSelectedRow, "date")
        }

        XCTContext.runActivity(named: "Move") { (_) in
            let moveExpectation = expectation(description: "Move")

            let deletedIndexPath = IndexPath(row: 2, section: 0)
            let insertedIndexPath = IndexPath(row: 3, section: 0)

            tableView.performBatchUpdates {
                dataSource.allData.swapAt(2, 3)
                tableView.deleteRows(at: [deletedIndexPath], with: .automatic)
                tableView.insertRows(at: [insertedIndexPath], with: .automatic)
            } completion: { [unowned self] (_) in
                self.context.setReselect()
                moveExpectation.fulfill()
            }

            wait(for: [moveExpectation], timeout: 1.0)

            XCTAssertEqual(context.pendingIndexPathForSelectedRow, IndexPath(row: 3, section: 0))
            XCTAssertEqual(context.pendingItemForSelectedRow, "date")
        }

        XCTContext.runActivity(named: "Insert") { (_) in
            let insertExpectation = expectation(description: "Insert")

            let insertedIndexPath = IndexPath(row: 3, section: 0)

            tableView.performBatchUpdates {
                dataSource.allData.insert("Orange", at: 3)
                tableView.insertRows(at: [insertedIndexPath], with: .automatic)
            } completion: { [unowned self] (_) in
                self.context.setReselect()
                insertExpectation.fulfill()
            }

            wait(for: [insertExpectation], timeout: 1.0)

            XCTAssertEqual(context.pendingIndexPathForSelectedRow, IndexPath(row: 4, section: 0))
            XCTAssertEqual(context.pendingItemForSelectedRow, "date")
        }

        XCTAssertNil(tableView.indexPathForSelectedRow)

        let expectedIndexPath = IndexPath(row: 4, section: 0)

        context.commit()
        XCTAssertEqual(dataSource.allData[tableView.indexPathForSelectedRow!.row], "date")
        XCTAssertEqual(tableView.indexPathForSelectedRow, expectedIndexPath)
    }


    static var allTests = [
        ("testMove", testMove),
        ("testDelete", testDelete),
        ("testMoveOnEdit", testMoveOnEdit),
        ("testInsertOnEdit", testInsertOnEdit),
        ("testDeleteOnEdit", testDeleteOnEdit),
        ("testNothingOnEdit", testNothingOnEdit),
        ("testSequenceOnEdit", testSequenceOnEdit)
    ]

}
