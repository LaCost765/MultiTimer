//
//  TimersViewController.swift
//  MultiTimer
//
//  Created by Egor on 02.09.2021.
//

import UIKit

class TimersViewController: UIViewController {

    // MARK: - Configure UI
    private var cells: [TimerTableViewCell] = []
    
    private let timerTitleTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Название таймера"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let timerDurationTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Время в секундах"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let addTimerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Добавить", for: .normal)
        button.addTarget(self, action: #selector(addTimerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(TimerTableViewCell.self, forCellReuseIdentifier: "TimerCell")
        
        return table
    }()
    
    private func setConstraints() {
        var constraints: [NSLayoutConstraint] = []
        
        constraints.append(timerTitleTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32))
        constraints.append(timerTitleTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32))
        constraints.append(timerTitleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 96))
        
        constraints.append(timerDurationTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32))
        constraints.append(timerDurationTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32))
        constraints.append(timerDurationTextField.topAnchor.constraint(equalTo: timerTitleTextField.bottomAnchor, constant: 16))
        
        constraints.append(addTimerButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor))
        constraints.append(addTimerButton.topAnchor.constraint(equalTo: timerDurationTextField.bottomAnchor, constant: 16))
        
        constraints.append(tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor))
        constraints.append(tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor))
        constraints.append(tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
        constraints.append(tableView.topAnchor.constraint(equalTo: addTimerButton.bottomAnchor, constant: 32))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Default methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(timerTitleTextField)
        view.addSubview(timerDurationTextField)
        view.addSubview(addTimerButton)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setConstraints()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Create and add cell
    @IBAction private func addTimerButtonTapped(_ sender: UIButton) {
        guard let title = timerTitleTextField.text,
              let secondsString = timerDurationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let secondsInt = Int(secondsString)
        else {
            let alert = UIAlertController(title: "Ошибка", message: "Неверно указана длительность таймера!", preferredStyle: .alert)
            let action = UIAlertAction(title: "ОК", style: .destructive, handler: nil)
            alert.addAction(action)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
        
        createCell(title: title, seconds: secondsInt)
    }
    
    private func createCell(title: String, seconds: Int) {
        let model = TimerModel(title: title, seconds: seconds)
        let viewModel = TimerViewModel(model: model)
        let cell = TimerTableViewCell(style: .default, reuseIdentifier: nil)
        cells.append(cell)
        cell.configure(vm: viewModel) { [weak self] in
            guard let self = self else { return }
            guard let index = self.cells.firstIndex(of: cell) else { return }
            self.cells.remove(at: index)
            self.refresh()
        }
        cells.sort { $0.viewModel!.timeLeft > $1.viewModel!.timeLeft }
        refresh()
    }
    
    private func refresh() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - Extensions for table view
extension TimersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        return cells[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}
