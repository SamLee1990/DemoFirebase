//
//  LoginViewController.swift
//  DemoFirebase
//
//  Created by 李世文 on 2021/9/5.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var fbLoginButtonView: UIView!
    
    //Firebase
    //當用戶的登入狀態發生變化時會調用此 Listener
    var handle: AuthStateDidChangeListenerHandle?
    
    //Facebook
    var fbLoginButton = FBLoginButton()
    
    var loadingView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //加入手勢，點擊收鍵盤
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardForTap))
        self.view.addGestureRecognizer(tap)
        
        registerForKeyboardNotifications()
        
        //Facebook
        fbLoginButton.delegate = self
        fbLoginButton.permissions = ["public_profile", "email"]
        fbLoginButtonView.addSubview(fbLoginButton)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //Facebook
        fbLoginButton.frame.origin = CGPoint(x: 0, y: 0)
        fbLoginButton.frame.size = fbLoginButtonView.frame.size
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Firebase
        handle = Auth.auth().addStateDidChangeListener({ [weak self] auth, user in
            print("---觸發監聽器---LoginViewController")
            guard let self = self else { return }
            
            if let _ = user,
               self.presentedViewController == nil {
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                self.performSegue(withIdentifier: "LoginSuccessSegue", sender: nil)
            }
            
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setLoadingView(false)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @objc func dismissKeyboardForTap(){
        self.view.endEditing(true)
    }
    
    @IBAction func dismissKeyboard(_ sender: UITextField) {}
    
    @IBAction func dissmissKeyboardWithRegisterButton(_ sender: Any) {
        view.endEditing(true)
    }
    
    func setLoadingView(_ status: Bool) {
        if status {
            //加入毛玻璃效果 xib
            if let array = Bundle.main.loadNibNamed("LoadingView", owner: nil, options: nil) {
                loadingView = array.first as? UIView
                loadingView?.frame.origin = CGPoint(x: 0, y: 0)
                loadingView?.frame.size = UIScreen.main.bounds.size
                if loadingView != nil {
                    view.addSubview(loadingView!)
                }
            }
        } else {
            //移除
            loadingView?.removeFromSuperview()
        }
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
        
        setLoadingView(true)
        //Firebase
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            guard error == nil else {
                self.setLoadingView(false)
                if let errorInfo = error?.localizedDescription {
                    print("---登入失敗---\(errorInfo)")
                    self.alert(title: errorInfo)
                }
                return
            }
            
        }
    }
    
    @IBAction func googleLogin(_ sender: Any) {
        //Google
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let authentication = user?.authentication,
                  let idToken = authentication.idToken else {
                return
            }
            print("Google 登入成功")
            setLoadingView(true)
            //Firebase
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { [weak self] result, error in
                guard let self = self else {
                    self?.setLoadingView(false)
                    return
                }
                guard error == nil else {
                    self.setLoadingView(false)
                    self.alert(title: "\(error!.localizedDescription)")
                    return
                }
                
                print("Firebase 登入成功")
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

//Facebook
extension LoginViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard error == nil else {
            print("登入失敗 \(error!.localizedDescription)")
            alert(title: error!.localizedDescription)
            return
        }
        
        guard let token = result?.token else { return }
        
        print("FB 登入成功")
        setLoadingView(true)
        //Firebase
        let credential = FacebookAuthProvider.credential(withAccessToken: token.tokenString)
        
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            guard let self = self else {
                self?.setLoadingView(false)
                return
            }
            guard error == nil else {
                self.setLoadingView(false)
                print("Firebase 登入失敗 \(error!.localizedDescription)")
                self.alert(title: "\(error!.localizedDescription)")
                return
            }
            
            print("Firebase 登入成功")
        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("fb 登出")
    }
    

}


//鍵盤出現時利用 notification 移動畫面
extension LoginViewController {
    
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
