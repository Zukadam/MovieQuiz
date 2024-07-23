import UIKit

class AlertPresenter: AlertPresenterProtocol {
    weak var delegate: AlertPresenterDelegete?
    weak var viewController: UIViewController?
    
    init(delegate: AlertPresenterDelegete?, viewController: UIViewController?) {
        self.delegate = delegate
        self.viewController = viewController
    }
    
    func show(quiz result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            result.completion()
        }
        
        alert.addAction(action)
        viewController?.present(alert, animated: true)
    }
}
