//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 20.09.24.
//

import Foundation

public protocol OnboardingDelegate {
    
    func requestNotificationsPermission() async throws
}
