import UIKit

protocol AlertDelegate: AnyObject {
    func didReceiveAlert(alert: UIAlertController?)
}
