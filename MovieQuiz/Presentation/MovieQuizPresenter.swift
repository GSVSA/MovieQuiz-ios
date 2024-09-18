import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let statisticService: StatisticServiceProtocol!
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0 // Индекс текущего вопроса
    var correctAnswers = 0 // Количество правильных ответов
    var currentQuestion: QuizQuestion?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
            currentQuestionIndex = 0
            correctAnswers = 0
            questionFactory?.requestNextQuestion()
        }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // MARK: - Actions
    
    func yesButtonClicked() {
        checkAnswer(true)
    }
    
    func noButtonClicked() {
        checkAnswer(false)
    }
    
    // Проверка ответа
    private func checkAnswer(_ answer: Bool) {
        let correctAnswer = currentQuestion?.correctAnswer
        showAnswerResult(isCorrect: correctAnswer == answer)
    }
    
    // Конвертирование формата вопроса в UI-модель
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel.init(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1) / \(questionsAmount)"
        )
        
        return questionStep
    }
    
    // Отображение результата проверки ответа
    private func showAnswerResult(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        if isCorrect {
            correctAnswers += 1
        }
           
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    // Показать следующий вопрос или результат
    private func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let currentResult = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
            let gamesCountMessage = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let bestGameCorrectCountMessage = "\(statisticService.bestGame.correct)"
            let bestGameTotalMessage = "\(statisticService.bestGame.total)"
            let bestGameDateMessage = "\(statisticService.bestGame.date.formatted())"
            let bestGameMessage = "Рекорд: \(bestGameCorrectCountMessage)/\(bestGameTotalMessage) (\(bestGameDateMessage))"
            let totalAccuracyMessage = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            let message = "\(currentResult)\n\(gamesCountMessage)\n\(bestGameMessage)\n\(totalAccuracyMessage)"
            
            viewController?.show(quiz: QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть ещё раз")
            )
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        
        let quiz = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: quiz)
        }
    }
      
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
}
