//
//  LoginViewController.swift
//  NewsProfile
//
//  Created by Apple on 17/05/25.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
class LoginViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }
    @IBAction func googleSignInTapped(_ sender: UIButton) {
        
        // Ensure the Firebase client ID is available
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Error: Firebase clientID not found.")
            return
        }
        
        // Configure Google Sign-In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the Google Sign-In process
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Google Sign-In failed with error: \(error.localizedDescription)")
                return
            }
            
            // Retrieve user details and tokens
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Error: Failed to retrieve user or ID token.")
                return
            }
            
            // Create Firebase credentials
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            // Authenticate with Firebase using the Google credentials
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase authentication failed: \(error.localizedDescription)")
                    return
                }
                self.navigateToHome()
                UserDefaults.standard.set(true, forKey: "AutoLogin")
                self.saveUserDetails(authResult?.user)
            }
        }
        
        
    }
    
    private func saveUserDetails(_ user: User?) {
        guard let user = user else { return }
        
        UserDefaults.standard.set(user.email, forKey: "UseEmail")
        UserDefaults.standard.set(user.displayName, forKey: "UseName")
        UserDefaults.standard.set(user.phoneNumber, forKey: "UsePhone")
        UserDefaults.standard.set(user.photoURL?.absoluteString, forKey: "UseProfileImg")
    }
    
    private func navigateToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        homeVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
}
