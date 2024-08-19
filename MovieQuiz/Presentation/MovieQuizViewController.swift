import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        
        setupView()
        
        activityIndicator.hidesWhenStopped = true
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory.loadData()
        
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
        
        let alertPresenter = AlertPresenter(delegate: self)
        self.alertPresenter = alertPresenter
        
        let statisticService = StatisticService()
        self.statisticService = statisticService
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
        changeStateButton(isEnabled: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
        changeStateButton(isEnabled: false)
    }
    
    // MARK: - Private Methods
    private func setupView() {
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionTitleLabel.textColor = .ypWhiteIOS
        questionTitleLabel.backgroundColor = .ypBlackIOS
        
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        indexLabel.textColor = .ypWhiteIOS
        indexLabel.backgroundColor = .ypBlackIOS
        
        previewImage.backgroundColor = .ypWhiteIOS
        previewImage.layer.cornerRadius = 20
        
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        questionLabel.textColor = .ypWhiteIOS
        questionLabel.backgroundColor = .ypBlackIOS
        
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.tintColor = .ypBlackIOS
        yesButton.backgroundColor = .ypWhiteIOS
        yesButton.layer.cornerRadius = 15

        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.tintColor = .ypBlackIOS
        noButton.backgroundColor = .ypWhiteIOS
        noButton.layer.cornerRadius = 15
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect { correctAnswers += 1 }
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        guard let statisticService else {
            print("Error: statisticService is nil")
            return
        }
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            let questionsAmount = presenter.questionsAmount
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
                    self?.presenter.resetQuestionIndex()
                    self?.correctAnswers = 0
                    self?.questionFactory?.requestNextQuestion()
                })
            
            alertPresenter?.show(quiz: alertModel)
            
            previewImage.layer.borderWidth = 0

            } else {
                presenter.switchToNextQuestion()
                previewImage.layer.borderWidth = 0
                self.questionFactory?.requestNextQuestion()
        }
        changeStateButton(isEnabled: true)
    }
    
    private func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating() // выключаем анимацию
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                self?.presenter.resetQuestionIndex()
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            })
        
        alertPresenter?.show(quiz: alertModel)
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
        questionLabel.text = step.question
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
}

extension MovieQuizViewController: AlertPresenterDelegate {
    func show(quiz result: AlertModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.message,
            buttonText: result.buttonText,
            completion: { [weak self] in
                self?.presenter.resetQuestionIndex()
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.show(quiz: alertModel)
    }
}
