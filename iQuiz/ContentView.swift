//
//  ContentView.swift
//  iQuiz
//
//  Created by Jung H Hwang on 5/12/25.
//

import SwiftUI

struct ContentView: View {
    // reuse your Part 1 in-memory data, but now include questions
    let quizzes: [Quiz] = [
        Quiz(
            title: "Mathematics",
            description: "Test your math skills",
            iconName: "mathIcon",   // your asset‐catalog icon
            questions: [
                Question(
                    text: "What is 7 × 8?",
                    options: ["54", "56", "48", "49"],
                    correctIndex: 1
                ),
                Question(
                    text: "What is the derivative of x²?",
                    options: ["2x", "x", "x²", "1"],
                    correctIndex: 0
                )
            ]
        ),
        Quiz(
            title: "Marvel Super Heroes",
            description: "How well do you know Marvel heroes?",
            iconName: "marvelIcon",
            questions: [
                Question(
                    text: "Tony Stark is also known as…?",
                    options: ["Spider-Man", "Iron Man", "Black Widow", "Hulk"],
                    correctIndex: 1
                )
            ]
        ),
        Quiz(
            title: "Science",
            description: "Explore science trivia",
            iconName: "scienceIcon",
            questions: [
                Question(
                    text: "What planet is known as the Red Planet?",
                    options: ["Venus", "Mars", "Jupiter", "Saturn"],
                    correctIndex: 1
                )
            ]
        )
    ]
    
    var body: some View {
        NavigationView {
            List(quizzes) { quiz in
                NavigationLink(destination: QuizFlowView(quiz: quiz)) {
                    HStack(spacing: 12) {
                        Image(quiz.iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading) {
                            Text(quiz.title)
                                .font(.headline)
                            Text(quiz.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("iQuiz")
        }
    }
}



#Preview {
    ContentView()
}
