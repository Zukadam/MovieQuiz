import Foundation

struct AlertModel {
    // текст заголовка
    let title: String
    // текст сообщения алерта
    let message: String
    // текст кнопки алерта
    let buttonText: String
    // замыкание без параметров для действия по кнопке алерта completion
    let completion: () -> Void
}
