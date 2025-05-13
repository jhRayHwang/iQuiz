//
//  QuizFlowView.swift
//  iQuiz
//
//  Created by Jung H Hwang on 5/12/25.
//

import SwiftUI

struct QuizFlowView: View {
    let quiz: Quiz
    
    @State private var currentQ = 0
    @State private var score = 0
    @State private var selected: Int? = nil
    @State private var showingAnswer = false
    @Environment(\.presentationMode) private var presentationMode
    
    private var isFinished: Bool { currentQ >= quiz.questions.count }
    private var q: Question { quiz.questions[currentQ] }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: Main Content
            Group {
                if isFinished {
                    finishedScene
                } else if showingAnswer {
                    answerScene
                } else {
                    questionScene
                }
            }
            .padding()
            .frame(maxHeight: .infinity)
            
            // MARK: Swipe Zone
            swipeZone
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .animation(.easeInOut, value: currentQ)
    }
    
    // MARK: Scenes
    
    private var questionScene: some View {
        VStack(spacing: 24) {
            Text(q.text)
                .font(.title2)
                .multilineTextAlignment(.center)
            
            ForEach(q.options.indices, id: \.self) { idx in
                Button {
                    selected = idx
                } label: {
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
            
            if selected == q.correctIndex {
                Text("Right!").foregroundColor(.green)
            } else {
                Text("Wrong").foregroundColor(.red)
            }
            
            Text("Correct answer:")
                .font(.headline)
            Text(q.options[q.correctIndex])
                .bold()
            
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
            Button("Next") {
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
    
    // MARK: Swipe Zone
    
    private var swipeZone: some View {
        Text("Swipe → to Submit/Next   |   ← to Abandon")
            .font(.footnote)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .contentShape(Rectangle())  // make entire area tappable/swipeable
            .padding(.bottom, 30)
            .gesture(
                DragGesture(minimumDistance: 50, coordinateSpace: .local)
                    .onEnded { value in
                        guard abs(value.translation.height) < abs(value.translation.width) else {
                            return
                        }
                        if value.translation.width > 0 {
                            // swipe right
                            if showingAnswer {
                                goToNext()
                            } else if selected != nil {
                                submitAnswer()
                            }
                        } else {
                            // swipe left → abandon
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
            )
    }
}
