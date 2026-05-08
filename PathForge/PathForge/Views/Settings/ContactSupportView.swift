import SwiftUI

struct ContactSupportView: View {
    @State private var topic = "General"
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    private let topics = ["General", "Bug Report", "Feature Request", "Subscription", "Account"]

    private let feedbackBackendURL = "https://feedback-board.iocompile67692.workers.dev"

    var body: some View {
        Form {
            Section {
                Picker("Topic", selection: $topic) {
                    ForEach(topics, id: \.self) { Text($0) }
                }

                TextField("Name (optional)", text: $name)

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
            } header: {
                Text("Your Information")
            }

            Section {
                TextEditor(text: $message)
                    .frame(minHeight: 120)
            } header: {
                Text("Message")
            } footer: {
                if let error = errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    submitFeedback()
                } label: {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(isSubmitting ? "Sending..." : "Submit Feedback")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canSubmit ? Color.forgeBlue : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
                .disabled(!canSubmit || isSubmitting)
            }
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
        .navigationTitle("Contact Support")
        .alert("Thank You!", isPresented: $showSuccess) {
            Button("OK") { }
        } message: {
            Text("Your message has been sent. We'll get back to you soon.")
        }
    }

    private var canSubmit: Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        let trimmedMessage = message.trimmingCharacters(in: .whitespaces)
        return !trimmedEmail.isEmpty &&
        trimmedEmail.contains("@") &&
        trimmedEmail.contains(".") &&
        !trimmedMessage.isEmpty
    }

    private func submitFeedback() {
        isSubmitting = true
        errorMessage = nil

        guard let url = URL(string: feedbackBackendURL) else {
            errorMessage = "Unable to connect to server"
            isSubmitting = false
            return
        }

        Task {
            do {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.timeoutInterval = 30

                let body: [String: Any] = [
                    "topic": topic,
                    "name": name.trimmingCharacters(in: .whitespaces),
                    "email": email.trimmingCharacters(in: .whitespaces),
                    "message": message.trimmingCharacters(in: .whitespaces),
                    "app": "PathForge"
                ]
                request.httpBody = try JSONSerialization.data(withJSONObject: body)

                let (_, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }

                showSuccess = true
                message = ""
                email = ""
                name = ""
            } catch {
                errorMessage = "Failed to send. Please try again or email us at iocompile67692@gmail.com"
            }
            isSubmitting = false
        }
    }
}
