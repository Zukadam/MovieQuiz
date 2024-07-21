import Foundation

protocol AlertPresenterDelegete: AnyObject {
    func show(quiz result: QuizResultsViewModel)
    func showDefaultText()
}
extension AlertPresenterDelegete {
    func showDefaultText(){}

}
