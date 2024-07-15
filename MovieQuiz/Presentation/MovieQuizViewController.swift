import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    // MARK: - Private Properties
    // переменная с индексом текущего вопроса, начальное значение 0
    private var currentQuestionIndex = 0
    // переменная со счётчиком правильных ответов
    private var correctAnswers = 0
    // общее кол-во вопросов
    private let questionsAmount: Int = 10
    // фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    // вопрос который видит пользователь
    private var currentQuestion: QuizQuestion? // changed private in ../Models/QuizQuestion.swift
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
//        self.show(quiz: convert(model: questions[currentQuestionIndex]))
        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            let viewModel = convert(model: firstQuestion)
            show(quiz: viewModel)
        }
    }
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: Any) {
//        let currentQuestion = questions[currentQuestionIndex]
        guard let currentQuestion else { return }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        changeStateButton(isEnabled: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
//        let currentQuestion = questions[currentQuestionIndex]
        guard let currentQuestion else { return }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        changeStateButton(isEnabled: false)
    }
    // MARK: - Private Methods
    // метод для насторойки UI элементов
    private func setupView() {
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionTitleLabel.textColor = .ypWhiteIOS
        questionTitleLabel.backgroundColor = .ypBlackIOS
        
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        indexLabel.textColor = .ypWhiteIOS
        indexLabel.backgroundColor = .ypBlackIOS
        
        previewImage.backgroundColor = .ypWhiteIOS
        previewImage.layer.cornerRadius = 20
        //TESTING
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
    
    // метод для включения выключения кнопок
    private func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса
    private func show(quiz step: QuizStepViewModel) {
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
        questionLabel.text = step.question
    }
    
    // приватный метод, который меняет цвет рамки
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect { correctAnswers += 1 }
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
           // код, который мы хотим вызвать через 0.5 секунды
            self.showNextQuestionOrResults()
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 { // if currentQuestionIndex == questions.count - 1
            let text = correctAnswers == questionsAmount ?
                "Поздравляем, вы ответили на 10 из 10!" :
                "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"// let text = "Ваш результат: \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
            previewImage.layer.borderWidth = 0

            } else { // 2
                currentQuestionIndex += 1
                // идём в состояние "Вопрос показан"
//                let nextQuestion = questions[currentQuestionIndex]
//                let viewModel = convert(model: nextQuestion)
//                previewImage.layer.borderWidth = 0
//                show(quiz: viewModel)
                if let nextQuestion = questionFactory.requestNextQuestion() {
                    currentQuestion = nextQuestion
                    let viewModel = convert(model: nextQuestion)
                    show(quiz: viewModel)
                }
                
        }
        changeStateButton(isEnabled: true)
    }
    
    // приватный метод для показа результатов раунда квиза
    private func show(quiz result: QuizResultsViewModel) {
        // код создания и показа алерта с результатами
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
//            let firstQuestion = self.questions[self.currentQuestionIndex]
//            let viewModel = self.convert(model: firstQuestion)
//            self.show(quiz: viewModel)
            if let firstQuestion = self.questionFactory.requestNextQuestion() {
                self.currentQuestion = firstQuestion
                let viewModel = self.convert(model: firstQuestion)
                self.show(quiz: viewModel)
            }
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
