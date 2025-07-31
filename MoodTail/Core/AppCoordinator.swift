//
//  AppCoordinator.swift
//  MoodTail
//
//  Created by Nikita Voitkus on 31/07/2025.
//

import SwiftUI
import Combine

@MainActor
class AppCoordinator: ObservableObject {
    @Published var currentRoute: AppRoute = .dashboard
    
    enum AppRoute {
        case dashboard
        case moodLogger
        case history
        case settings
    }
    
    func navigate(to route: AppRoute) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentRoute = route
        }
    }
    
    func goBack() {
        // Логика возврата назад
    }
} 