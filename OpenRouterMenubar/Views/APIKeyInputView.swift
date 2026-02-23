import SwiftUI
import AppKit

struct APIKeyInputView: View {
    @ObservedObject var viewModel: CreditsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Status
            Group {
                if viewModel.hasAPIKey {
                    Label("API key is stored in Keychain", systemImage: "key")
                        .foregroundStyle(.green)
                } else {
                    Label("No API key configured", systemImage: "key")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 20)

            // API Key section
            VStack(alignment: .leading, spacing: 10) {
                Text("API Key")
                    .font(.headline)

                if viewModel.hasAPIKey {
                    SecureField("", text: .constant(String(repeating: "x", count: 50)))
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                        .disabled(true)
                } else {
                    SecureField("", text: $viewModel.apiKeyInput)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                        .onSubmit { viewModel.saveAPIKey() }
                }

                HStack {
                    if !viewModel.hasAPIKey {
                        Button("Save Key") {
                            viewModel.saveAPIKey()
                        }
                        .disabled(viewModel.apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    } else {
                        Button("Remove Key", role: .destructive) {
                            viewModel.clearAPIKey()
                        }
                    }
                }
                .padding(.top, 6)
            }

            if let error = viewModel.errorMessage {
                Label(error, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 380, height: 260)
        .navigationTitle("ORbit Settings")
        .background(WindowFloatingHelper())
    }
}

private struct WindowFloatingHelper: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            view.window?.level = .floating
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
