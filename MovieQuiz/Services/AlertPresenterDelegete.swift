import Foundation

protocol AlertPresenterDelegete: AnyObject {
    func show(quiz result: AlertModel)
}
