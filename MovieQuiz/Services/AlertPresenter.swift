import UIKit
// show(quiz result: QuizResultsViewModel). Он отвечает за отображение алерта с результатами квиза после прохождения всех вопросов.
// Отображением другого экрана необязательно должен заниматься именно MovieQuizViewController. Вынесите эту логику в отдельный класс AlertPresenter. Чтобы передавать данные для отображения, создайте структуру AlertModel ...
class AlertPresenter {
    weak var delegate: AlertPresenterDelegete?
    init(delegate: AlertPresenterDelegete? = nil) {
        self.delegate = delegate
    }
}
