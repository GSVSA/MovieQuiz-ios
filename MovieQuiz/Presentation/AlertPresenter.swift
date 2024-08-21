import UIKit

final class AlertPresenter {
    private let alert: UIAlertController
    private let action: UIAlertAction
    
    weak var delegate: AlertDelegate?
    
    init(model: AlertModel, delegate: AlertDelegate? = nil) {
        self.delegate = delegate
        
        alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        alert.addAction(action)
    }
    
    func present() {
        delegate?.didReceiveAlert(alert: alert)
    }
}
