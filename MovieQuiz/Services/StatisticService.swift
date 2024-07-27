import Foundation

final class StatisticService {
    private enum Keys: String {
        case correct,
             gamesCount,
             bestGame,
             bestGameCorrect,
             bestGameTotal,
             bestGameDate,
             totalAccuracy
    }
    
    private let storage: UserDefaults
    private let dateProvider: () -> Date
    
    init(
        storage: UserDefaults = .standard,
        dateProvider: @escaping () -> Date = { Date() }
    ) {
        self.storage = storage
        self.dateProvider = dateProvider
    }
    
    var correct: Int {
        get { storage.integer(forKey: Keys.correct.rawValue) }
        set { storage.set(newValue, forKey: Keys.correct.rawValue) }
    }
}

extension StatisticService: StatisticServiceProtocol {
    var gamesCount: Int {
        get { storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    var bestGame: GameResult {
        get { GameResult(
            correct: storage.integer(forKey: Keys.bestGameCorrect.rawValue),
            total: storage.integer(forKey: Keys.bestGameTotal.rawValue),
            date: storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            )
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get { storage.double(forKey: Keys.totalAccuracy.rawValue) }
        set { storage.set(newValue, forKey: Keys.totalAccuracy.rawValue) }
    }
    
    func store(correct count: Int, total amount: Int) {
        correct += count
        gamesCount += 1
        totalAccuracy = (Double(correct) / Double(gamesCount * 10)) * 100

        let currentGame = GameResult(correct: count, total: amount, date: dateProvider())
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
    }
}
