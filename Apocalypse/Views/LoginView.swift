import SwiftUI

struct LoginView: View {
    @ObservedObject var authModel: AuthenticationModel
    @State private var username = ""
    @State private var password = ""
    @State private var isCreatingAccount = false
    @State private var showBiometricAuth = false
    
    // Theme colors
    private let darkGray = Color(red: 0.1, green: 0.1, blue: 0.1)
    private let eerieGreen = Color(red: 0.2, green: 0.8, blue: 0.2)
    private let bloodRed = Color(red: 0.8, green: 0.1, blue: 0.1)
    
    var body: some View {
        ZStack {
            // Background
            darkGray.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo and Title
                VStack(spacing: 10) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 60))
                        .foregroundColor(eerieGreen)
                    
                    Text("BOOM")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Post-Apocalyptic Barter Network")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 50)
                
                // Login Form
                VStack(spacing: 20) {
                    TextField("Username", text: $username)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    Button(action: {
                        if isCreatingAccount {
                            if authModel.createAccount(username: username, password: password) {
                                authModel.login(username: username, password: password)
                            }
                        } else {
                            authModel.login(username: username, password: password)
                        }
                    }) {
                        Text(isCreatingAccount ? "Create Account" : "Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(eerieGreen)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        authModel.authenticateWithBiometrics()
                    }) {
                        HStack {
                            Image(systemName: "faceid")
                            Text("Use Face ID")
                        }
                        .font(.subheadline)
                        .foregroundColor(eerieGreen)
                    }
                }
                .padding(.horizontal, 30)
                
                // Toggle between Login and Create Account
                Button(action: {
                    isCreatingAccount.toggle()
                }) {
                    Text(isCreatingAccount ? "Already have an account? Login" : "Need an account? Create one")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
        .alert("Error", isPresented: $authModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authModel.errorMessage)
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
            .cornerRadius(10)
            .foregroundColor(.white)
    }
}

#Preview {
    LoginView(authModel: AuthenticationModel())
} 