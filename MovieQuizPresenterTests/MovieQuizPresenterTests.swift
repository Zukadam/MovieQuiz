import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewProtocol {
    var vc: UIViewController = UIViewController()

    func highlightImageBorder(isCorrectAnswer: Bool) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
        
    func removeBorder() {
        
    }
    
    func proceedToNextQuestionOrResultsDone() {
        
    }
    
    func prepareUI(quiz step: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func changeStateButton(isEnabled: Bool) {
        
    }
    
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        _ = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter()
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
