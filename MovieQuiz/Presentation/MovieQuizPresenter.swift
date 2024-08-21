import UIKit

protocol MovieQuizPresenterProtocol {
    
    var view: MovieQuizViewProtocol? { get set }
    func noButtonClicked()
    func yesButtonClicked()
    func convert(model: QuizQuestion) -> QuizStepViewModel
    func loadData()
    func proceedWithAnswer(isCorrect: Bool)
    func didReceiveNextQuestion(question: QuizQuestion?)
}

final class MovieQuizPresenter: MovieQuizPresenterProtocol {

    private var correctAnswers = 0
    weak var view: MovieQuizViewProtocol?
    private let questionsAmount: Int = 10

    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private let statisticService = StatisticService()
    private var currentQuestionIndex: Int = 0

    func noButtonClicked() {
        answerGiven(answer: false)
    }
    
    func yesButtonClicked() {
        answerGiven(answer: true)
    }
    
    func loadData() {
        let alertPresenter = AlertPresenter(delegate: view?.vc)
        self.alertPresenter = alertPresenter
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        view?.showLoadingIndicator()
        questionFactory.loadData()

        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect { correctAnswers += 1 }
        view?.highlightImageBorder(isCorrectAnswer: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            proceedToNextQuestionOrResults()
        }
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
        proceedWithAnswer(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let questionsAmount = questionsAmount
            let text = correctAnswers == questionsAmount ?
                "Поздравляем, вы ответили на 10 из 10!" :
            """
            Ваш результат: \(correctAnswers)/10
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/10 (\(statisticService.bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    self?.restartGame()
                    self?.questionFactory?.requestNextQuestion()
                })
            
            alertPresenter?.show(quiz: alertModel)
            
            } else {
                switchToNextQuestion()
                self.questionFactory?.requestNextQuestion()
            }
        view?.proceedToNextQuestionOrResultsDone()
    }
}

extension MovieQuizPresenter: AlertPresenterDelegate {
    
    func show(quiz result: AlertModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.message,
            buttonText: result.buttonText,
            completion: { [weak self] in
                self?.restartGame()
                self?.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.show(quiz: alertModel)
    }
}

extension MovieQuizPresenter: QuestionFactoryDelegate {

    func show(quiz step: QuizStepViewModel) {
        view?.prepareUI(quiz: step)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        view?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()    }
    
    func didFailToLoadData(with error: any Error) {
        view?.hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: error.localizedDescription,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                self?.restartGame()
                self?.questionFactory?.requestNextQuestion()
            })
        
        alertPresenter?.show(quiz: alertModel)
    }
}
