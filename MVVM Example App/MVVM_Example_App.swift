//
//  MVVM_Example_AppApp.swift
//  MVVM Example App
//
//  Created by Abhiraj Chatterjee on 28/06/25.
//

// MARK: - Entry Point
import SwiftUI

@main
struct CounterApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

#Preview {
    RootView()
}

// MARK: - ViewModels/CounterViewModel.swift
import SwiftUI

/// 1. Feature-Level ViewModel: Coordinates all state for this feature.
class CounterViewModel: ObservableObject {
    @Published var countState = CountState()  // Count-specific logic
    @Published var inputEditor = InputEditorState()  // Live typing state
    @Published var inputOutput = SubmittedOutputState()  // Committed input display
}

/// 2. Modular State ViewModel: Handles count-only logic
class CountState: ObservableObject {
    @Published var count: Int = 0

    func increment() {
        count += 1
    }

    func decrement() {
        count -= 1
    }
}

/// 2. Modular State ViewModel: Handles real-time input
class InputEditorState: ObservableObject {
    @Published var userInput: String = ""
}

/// 2. Modular State ViewModel: Holds submitted/committed input
class SubmittedOutputState: ObservableObject {
    @Published var submittedText: String = ""

    func submit(_ text: String) {
        submittedText = text
    }
}

// MARK: - Views/RootView.swift
import SwiftUI

struct RootView: View {
    // 3. One-Time Dependency Injection
    @StateObject private var viewModel = CounterViewModel()

    var body: some View {
        CounterView()
            .environmentObject(viewModel.countState)
            .environmentObject(viewModel.inputEditor)
            .environmentObject(viewModel.inputOutput)
    }
}

// MARK: - Views/CounterView.swift
import SwiftUI

/// 4. High-Level Feature View: Composes modular views that observe just their slice of state
struct CounterView: View {
    var body: some View {
        VStack(spacing: 20) {
            CountSection()
            InputSection()
        }
        .padding()
    }
}

/// 5. Isolated UI Component: Re-renders only when CountState changes
struct CountSection: View {
    @EnvironmentObject var viewModel: CountState

    var body: some View {
        VStack {
            Text("Count: \(viewModel.count)")
                .font(.largeTitle)

            HStack(spacing: 40) {
                Button("-") { viewModel.decrement() }
                Button("+") { viewModel.increment() }
            }
            .font(.title)
        }
    }
}

/// 5. Isolated UI Component: TextField + Submit button
struct InputSection: View {
    @EnvironmentObject var inputEditor: InputEditorState
    @EnvironmentObject var inputOutput: SubmittedOutputState

    var body: some View {
        VStack(spacing: 16) {
            TextField("Enter something", text: $inputEditor.userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Submit") {
                inputOutput.submit(inputEditor.userInput)
            }

            SubmittedTextView(inputOutput.submittedText)
        }
    }
}

/// Subview that only rebuilds when submittedText changes (Stateless)
struct SubmittedTextView: View {
    let submittedText: String
    
    //this init is optional in this case
    //only used to accept the parameter as unnamed
    init(_ submittedText: String) {
        self.submittedText = submittedText
    }

    var body: some View {
        Text("You typed: \(submittedText)")
            .foregroundColor(.gray)
    }
}
