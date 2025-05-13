//
//  QuizModels.swift
//  iQuiz
//
//  Created by Jung H Hwang on 5/12/25.
//

import SwiftUI

struct Quiz: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let questions: [Question]
}

struct Question: Identifiable {
    let id = UUID()
    let text: String
    let options: [String]
    let correctIndex: Int
}
