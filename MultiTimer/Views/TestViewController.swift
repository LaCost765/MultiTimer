//
//  TestViewController.swift
//  MultiTimer
//
//  Created by Egor on 01.09.2021.
//

import UIKit
import RxSwift
import RxCocoa

class TestViewController: UIViewController {

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        // label.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        label.textColor = .darkGray
        return label
    }()
    
    private let stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.tintColor = .systemBlue
        //button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .systemBlue
        //button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        view.addSubview(stopButton)
        view.addSubview(playButton)
        
        view.backgroundColor = .systemBackground
        addConstraints()
        //createTimer(seconds: 30)
        subscription()
        // Do any additional setup after loading the view.
    }
    
    func subscription() {
        let isRunning = Observable.merge(playButton.rx.tap.map{ true }, stopButton.rx.tap.map{ false })
            .startWith(false)
            .share(replay: 1, scope: .whileConnected)
        
        let notRunning = isRunning.map { !$0 }.share(replay: 1, scope: .whileConnected)
        
        isRunning.bind(to: stopButton.rx.isEnabled)
        notRunning.bind(to: playButton.rx.isEnabled)
        
        let seconds = 10
        timer = Observable<Int>.interval(.milliseconds(100), scheduler: MainScheduler.instance)
            .withLatestFrom(isRunning, resultSelector: { $1 })
            .filter({ $0 })
            .scan((seconds + 1) * 10, accumulator: { acc, _ in
                acc - 1
            })
            .startWith(seconds * 10)
            .take((seconds) * 10)
            .share(replay: 1, scope: .whileConnected)
        
        timer.map(timeFromMilliseconds)
            .bind(to: label.rx.text)
    }
    
    func timeFromMilliseconds(ms: Int) -> String {
        return String(format: "%0.2d:%0.2d",
                      arguments: [(ms / 600) % 600, (ms % 600 ) / 10])
    }
    
    private var timer: Observable<Int>!
    
    private func addConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor))
        constraints.append(label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor))
        
        constraints.append(stopButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor))
        constraints.append(stopButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 32))
        
        constraints.append(playButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor))
        constraints.append(playButton.topAnchor.constraint(equalTo: stopButton.bottomAnchor, constant: 16))
        
        NSLayoutConstraint.activate(constraints)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
