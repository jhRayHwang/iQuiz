//
//  QuizStore.swift
//  iQuiz
//
//  Created by Jung H Hwang on 5/14/25.
//


import SwiftUI
import Combine

/// Your app’s single source of truth for quizzes and network logic
class QuizStore: ObservableObject {
    // MARK: Published state
    @Published var quizzes: [Quiz] = []
    @Published var networkErrorMessage: String = ""
    @Published var showNetworkError = false

    // MARK: Persistent settings
    @AppStorage("sourceURL") var sourceURL: String = "https://tednewardsandbox.site44.com/questions.json"
    @AppStorage("refreshInterval") var refreshInterval: TimeInterval = 60

    // MARK: Timer for auto-refresh
    private var timerCancellable: AnyCancellable?

    init() {
        load()            // initial download
        startTimer()      // begin timed refresh
    }

    /// Fetches JSON from `sourceURL` and decodes into `Quiz` models
    func load() {
        guard let url = URL(string: sourceURL) else {
            networkErrorMessage = "Bad URL"
            showNetworkError = true
            return
        }

        URLSession.shared.dataTask(with: url) { data, resp, err in
            DispatchQueue.main.async {
                if let err = err as NSError?,
                   err.domain == NSURLErrorDomain && err.code == NSURLErrorNotConnectedToInternet {
                    self.networkErrorMessage = "No network connection."
                    self.showNetworkError = true
                    return
                }

                guard let data = data else {
                    self.networkErrorMessage = "No data received."
                    self.showNetworkError = true
                    return
                }
                
                do {
                    // match JSON structure: [ { title, desc, questions: [ { text, answers, answer } ] } ]
                    let remote = try JSONDecoder().decode([RemoteQuiz].self, from: data)
                    // map to your existing Quiz/Question structs
                    self.quizzes = remote.map { rq in
                        Quiz(
                            title: rq.title,
                            description: rq.desc,
                            iconName: self.iconName(for: rq.title),
                            questions: rq.questions.map { rqq in
                                Question(
                                    text: rqq.text,
                                    options: rqq.answers,
                                    correctIndex: rqq.answerIndex
                                )
                            }
                        )
                    }
                } catch {
                    self.networkErrorMessage = "Decoding error: \(error.localizedDescription)"
                    self.showNetworkError = true
                }
            }
        }.resume()
    }

    /// Picks an icon name based on the quiz title
    private func iconName(for title: String) -> String {
        switch title.lowercased() {
        case let s where s.contains("math"):     return "mathIcon"
        case let s where s.contains("marvel"):   return "marvelIcon"
        case let s where s.contains("science"):  return "scienceIcon"
        default:                                 return "questionmark.circle"
        }
    }

    /// Starts or restarts the auto-refresh timer
    func startTimer() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: refreshInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.load()
            }
    }
}

// MARK: - Remote models matching JSON

private struct RemoteQuiz: Codable {
    let title: String
    let desc: String
    let questions: [RemoteQuestion]
}

private struct RemoteQuestion: Codable {
  let text: String
  let answers: [String]
  let answer: String      // still a String

  /// Convert the JSON “answer” (1-based string) → a Swift 0-based Int index
  var answerIndex: Int {
    let raw = Int(answer) ?? 1       // fallback to “1” if parse fails
    return max(0, raw - 1)           // subtract 1 & clamp at 0
  }
}


