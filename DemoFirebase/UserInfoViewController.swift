//
//  UserInfoViewController.swift
//  DemoFirebase
//
//  Created by 李世文 on 2021/9/5.
//

import UIKit
import Firebase

class UserInfoViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var uidLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
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
                //登入狀態
                print("---登入狀態 email:\(user.email ?? " no email")")
                self.nameLabel.text = user.displayName
                self.uidLabel.text = user.uid
                self.emailLabel.text = user.email
            } else {
                //登出狀態
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
        do {
            try Auth.auth().signOut()
        } catch {
            print("---登出失敗---\(error)")
        }
    }
    
    @IBAction func deleteUser(_ sender: Any) {
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
