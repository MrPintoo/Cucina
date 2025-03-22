import Foundation
import SwiftUI

class VotingService: ObservableObject {
    static let shared = VotingService()
    private let coreDataManager = CoreDataManager.shared
    
    @Published private(set) var polls: [Poll] = []
    
    private init() {
        loadPolls()
    }
    
    private func loadPolls() {
        polls = coreDataManager.fetchPolls()
    }
    
    func createPoll(title: String, description: String, options: [PollOption], duration: TimeInterval, createdBy: String) -> Poll {
        let poll = Poll(
            id: UUID(),
            title: title,
            description: description,
            options: options,
            createdBy: createdBy,
            createdAt: Date(),
            endsAt: Date().addingTimeInterval(duration),
            status: .active
        )
        
        coreDataManager.createPoll(poll)
        loadPolls()
        return poll
    }
    
    func vote(on poll: Poll, option: PollOption, userId: String) {
        var updatedPoll = poll
        if let optionIndex = updatedPoll.options.firstIndex(where: { $0.recipeId == option.recipeId }) {
            updatedPoll.options[optionIndex].votes += 1
            coreDataManager.updatePoll(updatedPoll)
            loadPolls()
        }
    }
    
    func getActivePolls() -> [Poll] {
        polls.filter { $0.status == .active && $0.endsAt > Date() }
    }
    
    func getCompletedPolls() -> [Poll] {
        polls.filter { $0.status == .ended || $0.endsAt <= Date() }
    }
    
    func getWinningRecipe(for poll: Poll) -> PollOption? {
        poll.options.max(by: { $0.votes < $1.votes })
    }
    
    func hasVoted(on poll: Poll, userId: String) -> Bool {
        // TODO: Implement voting history tracking
        false
    }
    
    func getVoteCount(for poll: Poll) -> Int {
        poll.options.reduce(0) { $0 + $1.votes }
    }
    
    func getVotePercentage(for option: PollOption, in poll: Poll) -> Double {
        let totalVotes = getVoteCount(for: poll)
        guard totalVotes > 0 else { return 0 }
        return Double(option.votes) / Double(totalVotes) * 100
    }
    
    func endPoll(_ poll: Poll) {
        var updatedPoll = poll
        updatedPoll.status = .ended
        coreDataManager.updatePoll(updatedPoll)
        loadPolls()
    }
    
    func deletePoll(_ poll: Poll) {
        coreDataManager.deletePoll(poll)
        loadPolls()
    }
}

struct Poll: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    var options: [PollOption]
    let createdBy: String
    let createdAt: Date
    let endsAt: Date
    var status: PollStatus
    var voters: [UUID] = []
}

struct PollOption: Codable {
    let recipeId: UUID
    var votes: Int
}

enum PollStatus: String, Codable {
    case active
    case ended
    case cancelled
} 
