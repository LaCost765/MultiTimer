//
//  TimerTableViewCell.swift
//  MultiTimer
//
//  Created by Egor on 01.09.2021.
//

import UIKit
import RxSwift

class TimerTableViewCell: UITableViewCell {

    
    // MARK: - Configure UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        return label
    }()
    
    private var stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    private var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    private func addConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16))
        
        constraints.append(durationLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constraints.append(durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16))
        constraints.append(durationLabel.widthAnchor.constraint(equalToConstant: 48))
        
        constraints.append(stopButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constraints.append(stopButton.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -16))
        
        constraints.append(playButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constraints.append(playButton.trailingAnchor.constraint(equalTo: stopButton.leadingAnchor, constant: -16))
        
        
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Configure View Model
    
    private(set) var viewModel: TimerViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                print("Timer view model was not initialized")
                return
            }
            
            guard let isRunning = viewModel.isRunning,
                  let notRunning = viewModel.notRunning,
                  let timer = viewModel.timer
            else { return }
            guard let bag = viewModel.bag else { return }
            
            viewModel.title.bind(to: titleLabel.rx.text).disposed(by: bag)
            isRunning.bind(to: stopButton.rx.isEnabled).disposed(by: bag)
            notRunning.bind(to: playButton.rx.isEnabled).disposed(by: bag)
            timer.bind(to: durationLabel.rx.text).disposed(by: bag)
            
            timer.subscribe(onCompleted: { [weak self] in
                self?.deleteClosure?()
                self?.viewModel?.unsub()
            }).disposed(by: bag)
        }
    }
    
    private var deleteClosure: (() -> Void)?
    
    func configure(vm: TimerViewModel, deleteCompletion: @escaping () -> Void) {
        deleteClosure = deleteCompletion
        vm.runTimer(playBtnTap: playButton.rx.tap, stopBtnTap: stopButton.rx.tap)
        viewModel = vm
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(playButton)
        contentView.addSubview(stopButton)
        contentView.addSubview(durationLabel)
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
