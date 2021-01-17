//
//  HapticHelper.swift
//  KSTimerView
//
//  Created by Karthick Selvaraj on 13/12/20.
//

import Foundation
import UIKit

class HapticHelper: NSObject {
    
    static let shared = HapticHelper()
    var isEnabled = true // Set this to false if you don't want haptic feedback.
    
    // MARK: - Private init method
    
    private override init() {
        super.init()
    }
    
    // MARK: - Custom methods
    
    func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .rigid) {
        if isEnabled {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
    
}
