//
//  ContentView.swift
//  iQuiz
//
//  Created by Jung H Hwang on 5/12/25.
//

// ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject private var store = QuizStore()
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            List {
                ForEach(store.quizzes) { quiz in
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
            }
            .navigationTitle("iQuiz")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("settings") {
                        showSettings = true
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(store)
            }
            // Extra credit: pull-to-refresh
            .refreshable {
                store.load()
            }
        }
    }
}



#Preview {
    ContentView()
}
