//
//  TimerModel.swift
//  MultiTimer
//
//  Created by Egor on 01.09.2021.
//

import Foundation

class TimerModel {
    
    let title: String
    var seconds: Int
    
    init(title: String, seconds: Int) {
        self.title = title
        self.seconds = seconds
    }
}
