//  QuizStore.swift
//  iQuiz
//  Created by Jung H Hwang on 5/14/25.

import SwiftUI
import Combine

/// Your app’s single source of truth for quizzes, network logic, and offline caching
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

    // MARK: Local cache file URL
    private var cacheURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("cached_quizzes.json")
    }

    init() {
        load()            // initial download or cache fallback
        startTimer()      // begin timed refresh
    }

    /// Fetches JSON from `sourceURL`; on success caches to disk, on failure loads from disk
    func load() {
        guard let url = URL(string: sourceURL) else {
            networkError("Bad URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, err in
            DispatchQueue.main.async {
                // network unreachable → offline fallback
                if let nsErr = err as NSError?,
                   nsErr.domain == NSURLErrorDomain,
                   nsErr.code == NSURLErrorNotConnectedToInternet {
                    self.loadFromDisk()
                    return
                }

                guard let data = data else {
                    self.networkError("No data received.")
                    return
                }

                do {
                    // decode remote JSON
                    let remote = try JSONDecoder().decode([RemoteQuiz].self, from: data)
                    // map and publish
                    self.quizzes = self.map(remote)
                    // cache raw JSON for offline use
                    try data.write(to: self.cacheURL, options: .atomic)
                } catch {
                    // decoding or write error → fallback
                    self.networkError("Decoding error: \(error.localizedDescription)")
                    self.loadFromDisk()
                }
            }
        }.resume()
    }

    /// Reads cached JSON from disk and decodes into quizzes
    private func loadFromDisk() {
        do {
            let data = try Data(contentsOf: cacheURL)
            let remote = try JSONDecoder().decode([RemoteQuiz].self, from: data)
            self.quizzes = self.map(remote)
        } catch {
            networkError("Offline & no cache available.")
        }
    }

    /// Sets error message & toggles alert
    private func networkError(_ message: String) {
        self.networkErrorMessage = message
        self.showNetworkError = true
    }

    /// Maps remote model into your app’s Quiz/Question structs
    private func map(_ remote: [RemoteQuiz]) -> [Quiz] {
        remote.map { rq in
            Quiz(
                title:        rq.title,
                description:  rq.desc,
                iconName:     self.iconName(for: rq.title),
                questions:    rq.questions.map { rqq in
                    Question(
                        text:         rqq.text,
                        options:      rqq.answers,
                        correctIndex: rqq.answerIndex
                    )
                }
            )
        }
    }

    /// Picks an icon name based on the quiz title
    private func iconName(for title: String) -> String {
        switch title.lowercased() {
        case let s where s.contains("math"):     return "mathIcon"
        case let s where s.contains("marvel"):   return "marvelIcon"
        case let s where s.contains("science"):  return "scienceIcon"
        default:                                   return "questionmark.circle"
        }
    }

    /// Starts or restarts the auto-refresh timer
    func startTimer() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: refreshInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.load() }
    }
}

// MARK: - Remote models matching JSON

private struct RemoteQuiz: Codable {
    let title: String
    let desc:   String
    let questions: [RemoteQuestion]
}

private struct RemoteQuestion: Codable {
    let text:    String
    let answers: [String]
    let answer:  String      // JSON gives a 1-based string index

    /// Converts 1-based JSON string into a 0-based Swift index
    var answerIndex: Int {
        let raw = Int(answer) ?? 1
        return max(0, raw - 1)
    }
}
