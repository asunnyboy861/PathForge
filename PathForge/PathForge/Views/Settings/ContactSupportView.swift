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
            }

            Section {
                TextEditor(text: $message)
                    .frame(minHeight: 120)
            } header: {
                Text("Message")
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
                        Text("Submit")
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

                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
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
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        !message.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func submitFeedback() {
        isSubmitting = true
        errorMessage = nil

        guard let backendURL = ProcessInfo.processInfo.environment["FEEDBACK_BACKEND_URL"],
              !backendURL.isEmpty else {
            showSuccess = true
            isSubmitting = false
            message = ""
            return
        }

        Task {
            do {
                var request = URLRequest(url: URL(string: backendURL)!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let body: [String: Any] = [
                    "topic": topic,
                    "name": name,
                    "email": email,
                    "message": message,
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
                errorMessage = error.localizedDescription
            }
            isSubmitting = false
        }
    }
}
