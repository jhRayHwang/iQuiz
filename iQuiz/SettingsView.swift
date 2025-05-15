//
//  SettingsView.swift
//  iQuiz
//
//  Created by Jung H Hwang on 5/14/25.
//

// SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: QuizStore
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Data Source")) {
                    TextField("Source URL", text: $store.sourceURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    Button("Check Now") {
                        store.load()
                    }
                }
                Section(header: Text("Auto-Refresh Interval")) {
                    Stepper(value: $store.refreshInterval, in: 10...3600, step: 10) {
                        Text("\(Int(store.refreshInterval)) seconds")
                    }
                    .onChange(of: store.refreshInterval) {
                        store.startTimer()
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("Network Error", isPresented: $store.showNetworkError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(store.networkErrorMessage)
            }
        }
    }
}
