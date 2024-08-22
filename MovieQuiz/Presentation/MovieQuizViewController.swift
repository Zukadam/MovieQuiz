import UIKit
protocol MovieQuizViewProtocol: AnyObject {
    var vc: UIViewController { get }

    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func proceedToNextQuestionOrResultsDone()
    func prepareUI(quiz step: QuizStepViewModel)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewProtocol {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Public Properties
    var vc: UIViewController { self }

    // MARK: - Private Properties
    private var presenter: MovieQuizPresenterProtocol = MovieQuizPresenter()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.view = self
        
        setupView()
        
        activityIndicator.hidesWhenStopped = true
        
        presenter.loadData()
        
        }

    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
        changeStateButton(isEnabled: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
        changeStateButton(isEnabled: false)
    }
    
    // MARK: - Public Methods

    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    func proceedToNextQuestionOrResultsDone() {
        removeBorder()
        changeStateButton(isEnabled: true)
    }

    func prepareUI(quiz step: QuizStepViewModel) {
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
        questionLabel.text = step.question
    }


    // MARK: - Private Methods
    private func removeBorder() {
        previewImage.layer.borderWidth = 0
    }
    
    private func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
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
}
