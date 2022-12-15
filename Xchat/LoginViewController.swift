//
//  LoginViewController.swift
//  Xchat
//
//  Created by Beavean on 04.11.2022.
//

import UIKit
import ProgressHUD

final class LoginViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var passwordLabel: UILabel!
    @IBOutlet private weak var repeatPasswordLabel: UILabel!
    @IBOutlet private weak var signUpLabel: UILabel!

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var repeatPasswordTextField: UITextField!

    @IBOutlet private weak var resendEmailButtonOutlet: UIButton!
    @IBOutlet private weak var loginButtonOutlet: UIButton!
    @IBOutlet private weak var signUpButtonOutlet: UIButton!

    @IBOutlet private weak var repeatPasswordLineView: UIView!

    // MARK: - Properties

    private var isLogin = true

    private enum ActionType {
        case login
        case register
        case password
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUIFor(login: true)
        setupTextFieldDelegates()
        setupBackgroundTap()
    }

    // MARK: - IBActions

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if isDataInputedFor(type: isLogin ? .login : .register) {
            isLogin ? loginUser() : registerUser()
        } else {
            ProgressHUD.showFailed("All fields are required")
        }
    }

    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        if isDataInputedFor(type: .password) {
            resetPassword()
        } else {
            ProgressHUD.showFailed("Email is required.")
        }
    }

    @IBAction func resendEmailButtonPressed(_ sender: UIButton) {
        if isDataInputedFor(type: .password) {

        } else {
            ProgressHUD.showFailed("Email is required.")
        }
    }

    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        updateUIFor(login: sender.titleLabel?.text == "Log In")
        isLogin.toggle()
    }

    // MARK: - Setup

    private func setupTextFieldDelegates() {
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        repeatPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    private func setupBackgroundTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tap)
    }

    // MARK: - Selectors

    @objc private func textFieldDidChange(_ textField: UITextField) {
        updatePlaceholderLabels(textField: textField)
    }

    @objc private func backgroundTap() {
        view.endEditing(false)
    }

    // MARK: - Animations

    private func updateUIFor(login: Bool) {
        loginButtonOutlet.setTitle(login ? "Login" : "Register", for: .normal)
        signUpButtonOutlet.setTitle(login ? "Sign Up" : "Log In", for: .normal)
        signUpLabel.text = login ? "Don't have an account?" : "Have an account?"
        UIView.animate(withDuration: 0.5) {
            self.repeatPasswordTextField.isHidden = login
            self.repeatPasswordLabel.isHidden = login
            self.repeatPasswordLineView.isHidden = login
        }
    }

    private func updatePlaceholderLabels(textField: UITextField) {
        switch textField {
        case emailTextField:
            emailLabel.text = textField.hasText ? "Email" : ""
        case passwordTextField:
            passwordLabel.text = textField.hasText ? "Password" : ""
        case repeatPasswordTextField:
            repeatPasswordLabel.text = textField.hasText ? "Repeat Password" : ""
        default:
            break
        }
    }

    // MARK: - Helpers

    private func isDataInputedFor(type: ActionType) -> Bool {
        switch type {
        case .login:
            return emailTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false
        case .register:
            return emailTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false && repeatPasswordTextField.text?.isEmpty == false
        default:
            return emailTextField.text?.isEmpty == false
        }
    }

    private func loginUser() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        FirebaseUserListener.shared.loginUserWithEmail(email: email, password: password) { [weak self] error, isEmailVerified in
            if let error {
                ProgressHUD.showFailed(error.localizedDescription)
            } else {
                if isEmailVerified {
                    self?.goToApp()
                } else {
                    ProgressHUD.showFailed("Please verify your email.")
                    self?.resendEmailButtonOutlet.isHidden = false
                }
            }
        }
    }

    private func registerUser() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        if password.isEmpty == false && passwordTextField.text == repeatPasswordTextField.text {
            FirebaseUserListener.shared.registerUserWith(email: email, password: password) { [weak self] error in
                if let error {
                    ProgressHUD.showFailed(error.localizedDescription)
                } else {
                    ProgressHUD.showSuccess("Verification email has been sent.")
                    self?.resendEmailButtonOutlet.isHidden = false
                }
            }
        } else {
            ProgressHUD.showFailed("The passwords do not match.")
        }
    }

    private func resetPassword() {
        guard let email = emailTextField.text else { return }
        FirebaseUserListener.shared.resetPasswordFor(email: email) { error in
            if let error {
                ProgressHUD.showFailed(error.localizedDescription)
            } else {
                ProgressHUD.showSuccess("Please check your email for reset instructions.")
            }
        }
    }

    private func resendVerificationEmail() {
        guard let email = emailTextField.text else { return }
        FirebaseUserListener.shared.resendVerificationEmail(email: email) { error in
            if let error {
                ProgressHUD.showFailed(error.localizedDescription)
            } else {
                ProgressHUD.showSuccess("New verification email has been sent.")
            }
        }
    }

    // MARK: - Navigation

    private func goToApp() {
        guard let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as? UITabBarController else { return }
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true)
    }
}
