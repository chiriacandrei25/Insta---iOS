//
//  HomeViewController.swift
//  Insta
//
//  Created by user169878 on 4/26/20.
//  Copyright © 2020 Algopedia. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var posts = [Post]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        loadPosts()
    }
    
    func loadPosts(){
        FirebaseDatabase.Database.database().reference().child("posts").observe(.childAdded) {
            (snapshot:DataSnapshot) in
            print(Thread.isMainThread)
            if let dict = snapshot.value as? [String: Any]
            {
                if dict["user_id"] as? String == Auth.auth().currentUser!.uid {
                    let captionText = dict["caption"] as? String
                    let photoUrlString = dict["photoUrl"] as? String
                    if photoUrlString != "" {
                        let storageRef = Storage.storage().reference(forURL: photoUrlString!)
                        storageRef.downloadURL(completion: { (url, error) in
                            do {
                                let data = try Data(contentsOf: url!)
                                let image = UIImage(data: data as Data)
                                let post = Post(captionText: captionText ?? "", photo: image!)
                                self.posts.append(post)
                                self.tableView.reloadData()
                            }
                            catch {
                                print("Nu vrea!")
                            }
                        })
                    }
                }
            }
        }
    }
    
    @IBAction func logout_TouchUpInside(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
        self.present(signInVC, animated: true, completion: nil)
    }
}

extension HomeViewController:UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)
        cell.textLabel?.text = posts[indexPath.row].caption
        cell.imageView!.image = posts[indexPath.row].photo
        return cell
    }
}
