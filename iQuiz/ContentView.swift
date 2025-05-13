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
            iconName: "mathIcon",
            questions: [
                Question(
                    text: "What is 7 × 8?",
                    options: ["54","56","48","49"],
                    correctIndex: 1
                ),
                Question(
                    text: "What is 12 ÷ 3?",
                    options: ["2","3","4","6"],
                    correctIndex: 2
                ),
                Question(
                    text: "What is the square root of 81?",
                    options: ["7","8","9","10"],
                    correctIndex: 2
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
                    options: ["Spider-Man","Iron Man","Black Widow","Hulk"],
                    correctIndex: 1
                ),
                Question(
                    text: "Who wields Mjolnir?",
                    options: ["Loki","Thor","Odin","Hulk"],
                    correctIndex: 1
                ),
                Question(
                    text: "What’s the real name of Black Panther?",
                    options: ["T'Challa","Shuri","Nakia","M'Baku"],
                    correctIndex: 0
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
                    options: ["Venus","Mars","Jupiter","Saturn"],
                    correctIndex: 1
                ),
                Question(
                    text: "What is the chemical formula for water?",
                    options: ["HO","H₂","H₂O","O₂"],
                    correctIndex: 2
                ),
                Question(
                    text: "How many bones are in an adult human?",
                    options: ["201","206","210","215"],
                    correctIndex: 1
                )
            ]
        )
    ]

    @State private var showingSettings = false

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
            .toolbar {
                // settings button up top
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Settings") {
                    showingSettings = true
                    }
                }
            }
            .alert("Settings go here", isPresented: $showingSettings) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}



#Preview {
    ContentView()
}
