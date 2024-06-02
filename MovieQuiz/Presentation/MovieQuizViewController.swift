import UIKit

// UI-модель вопроса
private struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

// Алерт результата всего квиза
private struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

// Вопрос
private struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

private let mockQuestions: [QuizQuestion] = [
    QuizQuestion(image: "The Godfather",
                 text: "Рейтинг этого фильма больше чем 6?",
                 correctAnswer: true),
    QuizQuestion(image: "The Dark Knight",
                 text: "Рейтинг этого фильма больше чем 6?",
                 correctAnswer: true),
    QuizQuestion(image: "Kill Bill",
                 text: "Рейтинг этого фильма больше чем 6?",
                 correctAnswer: true),
    QuizQuestion(image: "The Avengers",
                 text: "Рейтинг этого фильма больше чем 6?",
                 correctAnswer: true),
    QuizQuestion(image: "Deadpool",
                 text: "Рейтинг этого фильма больше чем 6?",
                 correctAnswer: true),
    QuizQuestion(image: "The Green Knight",
                 text: "Рейтинг этого фильма больше чем 6?",
                 correctAnswer: true),
    QuizQuestion(image: "Old",
                 text: "Рейтинг этого фильма больше чем 6?",
                 correctAnswer: false),
    QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
                 text: "Рейтинг этого фильма больше чем 6?",
                 correctAnswer: false),
    QuizQuestion(image: "Tesla",
                 text: "Рейтинг этого фильма больше чем 6?",
                 correctAnswer: false),
    QuizQuestion(image: "Vivarium",
                 text: "Рейтинг этого фильма больше чем 6?",
                 correctAnswer: false)
]

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    
    private var currentQuestionIndex = 0 // Индекс текущего вопроса
    private var correctAnswers = 0 // Количество правильных ответов
    
    private let questions: [QuizQuestion] = mockQuestions
    
    private func initViewAttributes() {
        imageView.layer.cornerRadius = 20
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
        yesButton.titleLabel?.font = UIFont(name: "YS Display-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YS Display-Medium", size: 20)
        counterLabel.font = UIFont(name: "YS Display-Medium", size: 20)
        textLabel.font = UIFont(name: "YS Display-Bold", size: 23)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewAttributes()
        showCurrentQuiz()
    }
    
    // Проверка ответа
    private func checkAnswer(_ answer: Bool) {
        let correctAnswer = questions[currentQuestionIndex].correctAnswer
        showAnswerResult(isCorrect: correctAnswer == answer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        checkAnswer(true)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        checkAnswer(false)
    }
    
    // Конвертирование формата вопроса в UI-модель
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel.init(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1) / \(questions.count)"
        )
        
        return questionStep
    }
    
    // Показать квиз
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderWidth = 0
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    // Показать алерт
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
    
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.correctAnswers = 0
            self.currentQuestionIndex = 0
            self.showCurrentQuiz()
        }
        
        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }
    
    // Показать текущий квиз
    private func showCurrentQuiz() {
        let quiz = convert(model: questions[currentQuestionIndex])
        show(quiz: quiz)
    }
    
    // Отображение результата проверки ответа
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        if isCorrect {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
           self.showNextQuestionOrResults()
        }
    }
    
    // Показать следующий вопрос или результат
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            show(quiz: QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questions.count)",
                buttonText: "Сыграть ещё раз")
            )
        } else {
            currentQuestionIndex += 1
            showCurrentQuiz()
        }
    }
}
