import SwiftUI

@main
struct ORbitApp: App {
    @StateObject private var viewModel = CreditsViewModel()

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView(viewModel: viewModel)
        } label: {
            Text(viewModel.menuBarTitle)
        }
        .menuBarExtraStyle(.window)

        Settings {
            APIKeyInputView(viewModel: viewModel)
        }
    }
}
