//
//  LoginViewController.swift
//  DemoFirebase
//
//  Created by 李世文 on 2021/9/5.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //當用戶的登入狀態發生變化時會調用此 Listener
    var handle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        //加入手勢
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardForTap))
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener({ [weak self] auth, user in
            print("---觸發監聽器---LoginViewController")
            guard let self = self else { return }
            
            if let _ = user,
               self.presentedViewController == nil {
                self.performSegue(withIdentifier: "LoginSuccessSegue", sender: nil)
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
            }
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @objc func dismissKeyboardForTap(){
        self.view.endEditing(true)
    }
    
    @IBAction func dismissKeyboard(_ sender: UITextField) {}
    
    @IBAction func dissmissKeyboardWithRegisterButton(_ sender: Any) {
        view.endEditing(true)
    }
    
    
    func alert(title: String) {
        let controller = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }

    @IBAction func login(_ sender: Any) {
        view.endEditing(true)
        guard let email = emailTextField.text,
              email.isEmpty == false else {
            alert(title: "請輸入電子郵件地址")
            return
        }
        
        guard let password = passwordTextField.text,
              password.isEmpty == false else {
            alert(title: "請輸入密碼")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            guard error == nil else {
                if let errorInfo = error?.localizedDescription {
                    print("---登入失敗---\(errorInfo)")
                    self.alert(title: errorInfo)
                }
                return
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

