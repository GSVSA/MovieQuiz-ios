import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - Lifecycle
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private var presenter: MovieQuizPresenter!
    
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
        
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: ({ [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
            })
        )
        
        let presenter = AlertPresenter(model: alertModel, delegate: self)
        presenter.present()
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.currentQuestion = presenter.currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.currentQuestion = presenter.currentQuestion
        presenter.noButtonClicked()
    }
    
    // MARK: - functions
    
    // Показать квиз
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderWidth = 0
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    // Показать алерт
    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: ({ [weak self] in
                guard let self = self else { return }
                self.presenter.correctAnswers = 0
                self.presenter.restartGame()
            })
        )
        
        let presenter = AlertPresenter(model: alertModel, delegate: self)
        presenter.present()
    }
    
    // Отображение результата проверки ответа
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
}

// MARK: - extension

extension MovieQuizViewController: AlertDelegate {
    func didReceiveAlert(alert: UIAlertController?) {
        guard let alert = alert else {
            return
        }
        self.present(alert, animated: true, completion: nil)
    }
}
