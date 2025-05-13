//
//  QuizFlowView.swift
//  iQuiz
//
//  Created by Jung H Hwang on 5/12/25.
//

import SwiftUI

struct QuizFlowView: View {
    let quiz: Quiz
    
    // flow state
    @State private var currentQ = 0
    @State private var score = 0
    @State private var selected: Int? = nil
    @State private var showingAnswer = false
    @Environment(\.presentationMode) private var presentationMode
    
    private var isFinished: Bool { currentQ >= quiz.questions.count }
    private var q: Question { quiz.questions[currentQ] }
    
    var body: some View {
        Group {
            if isFinished {
                finishedScene
            } else if showingAnswer {
                answerScene
            } else {
                questionScene
            }
        }
        .navigationBarBackButtonHidden(true) // we provide our own
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    // abandon entirely
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .gesture(dragGesture)           // extra-credit swipes
        .overlay(discoverabilityHint)   // show hint text
        .animation(.easeInOut, value: currentQ)
        .padding()
    }
    
    // MARK: Scenes
    
    private var questionScene: some View {
        VStack(spacing: 24) {
            Text(q.text)
                .font(.title2)
                .multilineTextAlignment(.center)
            
            // options
            ForEach(q.options.indices, id: \.self) { idx in
                Button(action: {
                    selected = idx
                }) {
                    HStack {
                        Text(q.options[idx])
                        Spacer()
                        if selected == idx {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemFill))
                    .cornerRadius(8)
                }
            }
            
            Button("Submit") {
                submitAnswer()
            }
            .disabled(selected == nil)
        }
    }
    
    private var answerScene: some View {
        VStack(spacing: 24) {
            Text(q.text)
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Text("Correct answer:")
                .font(.headline)
            Text(q.options[q.correctIndex])
                .bold()
            
            if selected == q.correctIndex {
                Text("🎉 Right!").foregroundColor(.green)
            } else {
                Text("❌ Wrong").foregroundColor(.red)
            }
            
            Button("Next") {
                goToNext()
            }
        }
    }
    
    private var finishedScene: some View {
        VStack(spacing: 24) {
            Text(feedbackText)
                .font(.largeTitle)
            Text("You got \(score) of \(quiz.questions.count) correct.")
                .font(.title3)
            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private var feedbackText: String {
        switch score {
        case quiz.questions.count:
            return "Perfect!"
        case (quiz.questions.count - 1)...:
            return "Almost!"
        default:
            return "Finished"
        }
    }
    
    // MARK: Actions
    
    private func submitAnswer() {
        if let sel = selected, sel == q.correctIndex {
            score += 1
        }
        showingAnswer = true
    }
    
    private func goToNext() {
        currentQ += 1
        selected = nil
        showingAnswer = false
    }
    
    // MARK: Swipe gesture
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 50, coordinateSpace: .local)
            .onEnded { value in
                if abs(value.translation.height) < abs(value.translation.width) {
                    if value.translation.width > 0 {
                        // swipe right
                        if showingAnswer {
                            goToNext()
                        } else {
                            if selected != nil {
                                submitAnswer()
                            }
                        }
                    } else {
                        // swipe left → abandon quiz
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
    }
    
    // MARK: Discoverability Hint
    
    private var discoverabilityHint: some View {
        VStack {
            Spacer()
            Text("Swipe → to Submit/Next, ← to Abandon")
                .font(.footnote)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6).opacity(0.9))
        }
    }
}
