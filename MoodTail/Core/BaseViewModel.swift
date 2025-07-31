//
//  BaseViewModel.swift
//  MoodTail
//
//  Created by Nikita Voitkus on 31/07/2025.
//

import Foundation
import Combine

@MainActor
class BaseViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var cancellables = Set<AnyCancellable>()
    
    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    deinit {
        cancellables.removeAll()
    }
} 