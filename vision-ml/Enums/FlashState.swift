//
//  SwitchStatus.swift
//  vision-ml
//
//  Created by Cody Lee on 10/6/17.
//  Copyright © 2017 CJLeeApps. All rights reserved.
//

import Foundation

enum FlashState: Togglable {
    case on, off
    
    mutating func toggle() {
        switch self {
        case .on:
            self = .off
            
        case .off:
            self = .on
            
        }
    }
}
