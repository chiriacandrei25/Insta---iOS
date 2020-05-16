//
//  CameraViewController.swift
//  Insta
//
//  Created by user169878 on 4/26/20.
//  Copyright © 2020 Algopedia. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class CameraViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var removeButton: UIBarButtonItem!
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPhoto))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handlePost()
    }
    
    func handlePost() {
        print("E in handle")
        if selectedImage != nil {
           self.shareButton.isEnabled = true
           self.removeButton.isEnabled = true
            self.shareButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
           self.shareButton.isEnabled = false
            self.removeButton.isEnabled = false
            self.shareButton.backgroundColor = .lightGray

        }
    }
    
    @IBAction func remove_TouchUpInside(_ sender: Any) {
        clean()
        handlePost()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func handleSelectPhoto() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        print("merge?")
        present(pickerController, animated: true, completion: nil)
    }
    @IBAction func shareButton_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
        if let profileImg = self.selectedImage, let imageData = profileImg.jpegData(compressionQuality: 0.1)
        {
            let photoIdString = NSUUID().uuidString
            let storageRef = Storage.storage().reference(forURL: "gs://instagram-f17be.appspot.com").child("posts").child(photoIdString)
            storageRef.putData(imageData, metadata: nil, completion: { (_, error: Error?) in
                if error != nil {
                    return
                }
                storageRef.downloadURL(completion: { (url: URL?, error: Error?) in
                    if let photoUrl = url?.absoluteString {
                        self.sendDataToDatabase(photoUrl: photoUrl)
                    }
                })
            })
        }
        else {
            
        }
    }
    
    func sendDataToDatabase(photoUrl: String) {
        let ref = Database.database().reference()
        let postsReference = ref.child("posts")
        let newPostId = postsReference.childByAutoId().key!
        let newPostReference = postsReference.child(newPostId)
        newPostReference.setValue(["photoUrl": photoUrl, "caption": captionTextView.text!, "user_id": Auth.auth().currentUser!.uid], withCompletionBlock: {
            (error, ref) in
            if error != nil {
                //ProgressHUD.showError(error!.localizedDescription)
                return
            }
            //ProgressHUD.showSuccess("Success")
        })
        self.clean()		
        self.tabBarController?.selectedIndex = 0
    }
    
    func clean() {
        self.captionTextView.text = ""
        self.photo.image = UIImage(named: "Placeholder")
        self.selectedImage = nil
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("did Finish Picking Media")
        let image = info[UIImagePickerController.InfoKey.originalImage]
        selectedImage = image as? UIImage
        photo.image = image as? UIImage
        handlePost()
        dismiss(animated: true, completion: nil)
    }
    
}
