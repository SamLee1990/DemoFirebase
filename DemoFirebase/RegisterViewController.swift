//
//  RegisterViewController.swift
//  DemoFirebase
//
//  Created by 李世文 on 2021/9/5.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardForTap))
        self.view.addGestureRecognizer(tap)
        
        registerForKeyboardNotifications()
    }
    
    @objc func dismissKeyboardForTap(){
        self.view.endEditing(true)
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {}
    
    @IBAction func register(_ sender: Any) {
        view.endEditing(true)
        guard let email = emailTextField.text,
              email.isEmpty == false else {
            alert(title: "請輸入email")
            return
        }
        
        guard let password = passwordTextField.text,
              password.count > 5 else {
            alert(title: "密碼需大於(包含)6個字")
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text,
              confirmPassword.isEmpty == false else {
            alert(title: "請輸入密碼確認")
            return
        }
        
        guard let name = nameTextField.text,
              name.isEmpty == false else {
            alert(title: "請輸入暱稱")
            return
        }
        
        guard password == confirmPassword else {
            alert(title: "密碼 與 密碼確認 不相符，請重新輸入")
            passwordTextField.text = ""
            confirmPasswordTextField.text = ""
            return
        }
        
        //註冊
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authDataResult, error in
            guard let self = self else { return }
            guard let user = authDataResult?.user,
                  error == nil else {
                print("---註冊失敗---" + error!.localizedDescription)
                self.alert(title: error!.localizedDescription)
                return
            }
            print("---註冊成功--- email: \(user.email ?? "") --- uid: \(user.uid)")
            //設定匿名
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = name
            changeRequest?.commitChanges(completion: { [weak self] error in
                guard let self = self else { return }
                if error != nil {
                    print("---個人資料設定失敗---\(error!.localizedDescription)")
                } else {
                    print("---個人資料設定成功")
                }
                weak var pvc = self.presentingViewController
                self.dismiss(animated: true) {
                    pvc?.performSegue(withIdentifier: "LoginSuccessSegue", sender: nil)
                }
            })
            
        }
        
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func alert(title: String) {
        let controller = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(action)
        present(controller, animated: true, completion: nil)
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

//鍵盤出現時利用 notification 移動畫面
extension RegisterViewController {
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(_ notifiction: NSNotification) {
        guard let info = notifiction.userInfo,
        let keyboardFrameValue = info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardSize = keyboardFrame.size
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillBeHidden(_ notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
}
