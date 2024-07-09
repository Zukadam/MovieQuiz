import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    // MARK: - Private Structs
    private struct QuizQuestion {
        // строка с названием фильма,
        let image: String
        // строка с вопросом о рейтинге фильма
        let text: String
        // булевое значение (true, false), правильный ответ на вопрос
        let correctAnswer: Bool
    }
    // вью модель для состояния "Вопрос показан"
    private struct QuizStepViewModel {
        // картинка с афишей фильма с типом UIImage
        let image: UIImage
        // вопрос о рейтинге квиза
        let question: String
        // строка с порядковым номером этого вопроса (ex. "1/10")
        let questionNumber: String
    }
    // для состояния "Результат квиза"
    private struct QuizResultsViewModel {
        // строка с заголовком алерта
        let title: String
        // строка с текстом о количестве набранных очков
        let text: String
        // текст для кнопки алерта
        let buttonText: String
    }
    // MARK: - Private Properties
    // переменная с индексом текущего вопроса, начальное значение 0
    private var currentQuestionIndex = 0
    // переменная со счётчиком правильных ответов
    private var correctAnswers = 0
    // массив вопросов
    private let questions: [QuizQuestion] = [
            QuizQuestion(
                image: "The Godfather",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Dark Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Kill Bill",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Avengers",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Deadpool",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Green Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Old",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "The Ice Age Adventures of Buck Wild",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Tesla",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Vivarium",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false)
        ]
    // MARK: - Overrides Methods
    override func viewDidLoad() {
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
        
        self.show(quiz: convert(model: questions[currentQuestionIndex]))
        
        super.viewDidLoad()
    }
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    // MARK: - Private Methods
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel( // 1
            image: UIImage(named: model.image) ?? UIImage(), // 2
            question: model.text, // 3
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)") // 4
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
           // код, который мы хотим вызвать через 1 секунду
           self.showNextQuestionOrResults()
        }
    }
    // приватный метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
            previewImage.layer.borderWidth = 0

            } else { // 2
            currentQuestionIndex += 1
            // идём в состояние "Вопрос показан"
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
                previewImage.layer.borderWidth = 0
            show(quiz: viewModel)
        }
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    // приватный метод для показа результатов раунда квиза
    private func show(quiz result: QuizResultsViewModel) {
        // код создания и показа алерта с результатами
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
