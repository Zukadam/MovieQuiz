import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    weak var viewController: MovieQuizViewController?
    var currentQuestion: QuizQuestion?
    
    private var currentQuestionIndex: Int = 0

    func noButtonClicked() {
        answerGiven(answer: false)
    }
    
    func yesButtonClicked() {
        answerGiven(answer: true)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func answerGiven(answer: Bool) {
        guard let currentQuestion else { return }
        viewController?.showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }


}
