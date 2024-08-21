import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewProtocol {
    func highlightImageBorder(isCorrectAnswer: Bool) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    var vc: UIViewController = UIViewController()
    
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
        let viewControllerMock = MovieQuizViewControllerMock()
        
        let sut = MovieQuizPresenter()
        sut.view = viewControllerMock
        
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
