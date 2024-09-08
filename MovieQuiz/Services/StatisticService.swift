import Foundation

final class StatisticService {
    private enum Keys: String {
        case correct
        case total
        case date
        case bestGame
        case gamesCount
        case correctAnswers
        case questionsAmount
    }
    
    private let storage: UserDefaults = .standard
    
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    
    private var questionsAmount: Int {
        get {
            storage.integer(forKey: Keys.questionsAmount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.questionsAmount.rawValue)
        }
    }
}

extension StatisticService: StatisticServiceProtocol {
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.total.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        if questionsAmount < 1 {
            return 0
        }
        return Double(Double(correctAnswers) / Double(questionsAmount) * 100)
    }
    
    func store(correct count: Int, total amount: Int) {
        questionsAmount = questionsAmount + amount
        correctAnswers = correctAnswers + count
        gamesCount += 1
        
        let currentResult = GameResult(
            correct: count,
            total: amount,
            date: Date()
        )
        
        let currentIsBetter = !bestGame.isBetterThan(currentResult)
        
        if currentIsBetter {
            bestGame = currentResult
        }
    }
}
