import Foundation
import SwiftUI
import LocalAuthentication

class AuthenticationModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    private let keychainService = "com.apocalypse.boom"
    
    func createAccount(username: String, password: String) -> Bool {
        // Generate a unique device ID if it doesn't exist
        if UserDefaults.standard.string(forKey: "deviceID") == nil {
            let deviceID = UUID().uuidString
            UserDefaults.standard.set(deviceID, forKey: "deviceID")
        }
        
        // Store credentials securely in Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: username,
            kSecValueData as String: password.data(using: .utf8)!
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func login(username: String, password: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: username,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let storedPassword = String(data: data, encoding: .utf8),
              storedPassword == password else {
            return false
        }
        
        isAuthenticated = true
        return true
    }
    
    func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: "Authenticate to access BOOM") { success, error in
                DispatchQueue.main.async {
                    self.isAuthenticated = success
                    if !success {
                        self.errorMessage = error?.localizedDescription ?? "Authentication failed"
                        self.showError = true
                    }
                }
            }
        }
    }
} 