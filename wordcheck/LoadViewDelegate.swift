import UIKit

protocol LoadViewDelegate: AnyObject {
    func loadCreateTableView()
    func loadUpdateTableView()
    func loadDeleteTableView()
}
