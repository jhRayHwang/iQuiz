//
//  ViewController.swift
//  iQuiz
//
//  Created by Jung H Hwang on 5/2/25.
//

import UIKit

struct Quiz {
  let iconName: String
  let title: String
  let description: String
}

class ViewController: UIViewController {
  
  // Storyboard outlets
  @IBOutlet weak var tableView: UITableView!
  
  // Data source
  private var quizzes: [Quiz] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Wire up data source & delegate
    tableView.dataSource = self
    tableView.delegate   = self
    
    // Populate your in-memory quiz list
    quizzes = [
      Quiz(iconName: "mathIcon",
           title: "Mathematics",
           description: "Brush up on algebra, geometry…"),
      Quiz(iconName: "marvelIcon",
           title: "Marvel Super Heroes",
           description: "Test your MCU knowledge!"),
      Quiz(iconName: "scienceIcon",
           title: "Science",
           description: "Explore biology, physics…")
    ]

    tableView.reloadData()
  }
  
  // Called when the “Settings” toolbar button is tapped
  @IBAction func settingsTapped(_ sender: UIBarButtonItem) {
    let alert = UIAlertController(title: nil,
                                  message: "Settings go here",
                                  preferredStyle: .alert)
    alert.addAction(.init(title: "OK", style: .default))
    present(alert, animated: true)
  }
}


extension ViewController: UITableViewDataSource {
  func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
    quizzes.count
  }
  
  func tableView(_ tv: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // Make sure your prototype cell’s Identifier is “QuizCell”
    let cell = tv.dequeueReusableCell(withIdentifier: "QuizCell", for: indexPath) as! QuizCell
    let quiz = quizzes[indexPath.row]
    
    // Fill in the outlets you hooked up earlier
    cell.iconImageView.image      = UIImage(named: quiz.iconName)
    cell.titleLabel.text          = quiz.title
    cell.descriptionLabel.text    = quiz.description
    
    return cell
  }
}


extension ViewController: UITableViewDelegate {
  func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
    tv.deselectRow(at: indexPath, animated: true)
    // Later: push or present your quiz question screen here
  }
}

