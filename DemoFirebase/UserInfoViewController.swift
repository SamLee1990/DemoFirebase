//
//  UserInfoViewController.swift
//  DemoFirebase
//
//  Created by 李世文 on 2021/9/5.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn

class UserInfoViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var uidLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    //當用戶的登入狀態發生變化時會調用此 Listener
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            print("---觸發監聽器---UserInfoViewController")
            guard let self = self else { return }
            
            if let user = user {
                print("---登入狀態 uid: \(user.uid)")
                guard user.providerData.isEmpty == false else { return }
                
                var name: String?
                var email: String?
                var photoURL: URL?
                
                let providerInfo = user.providerData[0]
                print("providerID = \(providerInfo.providerID)")
                if providerInfo.providerID == "password" {
                    name = user.displayName
                    email = user.email
                    photoURL = user.photoURL
                } else {
                    name = providerInfo.displayName
                    email = providerInfo.email
                    photoURL = providerInfo.photoURL
                }
                self.uidLabel.text = user.uid
                self.nameLabel.text = name
                self.emailLabel.text = email
                if let photoURL = photoURL {
                    URLSession.shared.dataTask(with: photoURL) { data, response, error in
                        if let data = data,
                           error == nil {
                            DispatchQueue.main.async {
                                self.imageView.image = UIImage(data: data)
                            }
                        } else {
                            print("下載照片失敗 \(error!.localizedDescription)")
                        }
                    }.resume()
                }
            } else {
                print("---登出狀態")
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @IBAction func logOut(_ sender: Any) {
        //Google
        GIDSignIn.sharedInstance.signOut()
        //Facebook
        if let _ = AccessToken.current {
            LoginManager().logOut()
        }
        //Firebase
        do {
            try Auth.auth().signOut()
        } catch {
            print("---登出失敗---\(error)")
        }
    }
    
    @IBAction func deleteUser(_ sender: Any) {
        //Firebase
        guard let user = Auth.auth().currentUser else {
            print("---使用者未登入---")
            return
        }
        
        user.delete { error in
            if let error = error {
                print("---刪除失敗---\(error.localizedDescription)")
            } else {
                print("---刪除成功---")
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
