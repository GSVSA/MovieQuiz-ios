import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestionIndex = 0 // Индекс текущего вопроса
    private var correctAnswers = 0 // Количество правильных ответов
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private let statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - Lifecycle
    private func initViewAttributes() {
        imageView.layer.cornerRadius = 20
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
        yesButton.titleLabel?.font = UIFont(name: "YS Display Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YS Display Medium", size: 20)
        counterLabel.font = UIFont(name: "YS Display Medium", size: 20)
        textLabel.font = UIFont(name: "YS Display Bold", size: 23)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewAttributes()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: ({ [weak self] in
                guard let self = self else { return }
                self.questionFactory?.requestNextQuestion()
            })
        )
        
        let presenter = AlertPresenter(model: alertModel, delegate: self)
        presenter.present()
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        checkAnswer(true)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        checkAnswer(false)
    }
    
    // MARK: - Private functions
    
    // Проверка ответа
    private func checkAnswer(_ answer: Bool) {
        let correctAnswer = currentQuestion?.correctAnswer
        showAnswerResult(isCorrect: correctAnswer == answer)
    }
    
    // Конвертирование формата вопроса в UI-модель
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel.init(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1) / \(questionsAmount)"
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
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: ({ [weak self] in
                guard let self = self else { return }
                self.correctAnswers = 0
                self.currentQuestionIndex = 0
                self.questionFactory?.requestNextQuestion()
            })
        )
        
        let presenter = AlertPresenter(model: alertModel, delegate: self)
        presenter.present()
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
           self?.showNextQuestionOrResults()
        }
    }
    
    // Показать следующий вопрос или результат
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let currentResult = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
            let gamesCountMessage = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let bestGameCorrectCountMessage = "\(statisticService.bestGame.correct)"
            let bestGameTotalMessage = "\(statisticService.bestGame.total)"
            let bestGameDateMessage = "\(statisticService.bestGame.date.formatted())"
            let bestGameMessage = "Рекорд: \(bestGameCorrectCountMessage)/\(bestGameTotalMessage) (\(bestGameDateMessage))"
            let totalAccuracyMessage = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            let message = "\(currentResult)\n\(gamesCountMessage)\n\(bestGameMessage)\n\(totalAccuracyMessage)"
            
            show(quiz: QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть ещё раз")
            )
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate {
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        
        let quiz = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: quiz)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
}

extension MovieQuizViewController: AlertDelegate {
    func didReceiveAlert(alert: UIAlertController?) {
        guard let alert = alert else {
            return
        }
        self.present(alert, animated: true, completion: nil)
    }
}
