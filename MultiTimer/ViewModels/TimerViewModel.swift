//
//  TimerViewModel.swift
//  MultiTimer
//
//  Created by Egor on 02.09.2021.
//

import Foundation
import RxSwift
import RxCocoa

enum TimerState {
    case created
    case inProgress
    case done
}

class TimerViewModel {
    
    let model: TimerModel
    let title: BehaviorRelay<String>
    private(set) var timer: Observable<String>? = nil
    private(set) var isRunning: Observable<Bool>? = nil
    private(set) var notRunning: Observable<Bool>? = nil
    private(set) var timeLeft: Int
    private(set) var bag: DisposeBag? = DisposeBag()
    
    init(model: TimerModel) {
        self.model = model
        title = BehaviorRelay(value: model.title)
        timeLeft = model.seconds * 10
    }
    
    func runTimer(playBtnTap: ControlEvent<Void>, stopBtnTap: ControlEvent<Void>) {
        
        isRunning = Observable.merge(playBtnTap.map{ true }, stopBtnTap.map{ false })
            .startWith(true)
            .share(replay: 1, scope: .whileConnected)

        notRunning = isRunning!.map { !$0 }.share(replay: 1, scope: .whileConnected)
        
        let seconds = model.seconds
        // умножаем количество секунд на 10, потому что таймер срабатывает каждые 0.1 секунды
        timer = Observable<Int>.interval(.milliseconds(100), scheduler: MainScheduler.instance)
            .withLatestFrom(isRunning!, resultSelector: { $1 })
            .filter({ $0 })
            .scan((seconds + 1) * 10, accumulator: { [weak self] acc, _ in
                self?.timeLeft -= 1
                return acc - 1
            })
            .startWith(seconds * 10)
            .take((seconds) * 10)
            .share(replay: 1, scope: .whileConnected)
            .map({String(format: "%0.2d:%0.2d",
                         arguments: [($0 / 600) % 600, ($0 % 600 ) / 10])})
    }
    
    func unsub() {
        bag = nil
    }
}
