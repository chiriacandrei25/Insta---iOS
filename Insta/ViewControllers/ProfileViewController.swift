//
//  ProfileViewController.swift
//  Insta
//
//  Created by user169878 on 4/26/20.
//  Copyright © 2020 Algopedia. All rights reserved.
//

import UIKit
import Photos
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        loadPosts()
    }
    
    func loadPosts(){
        print("Heeey!")
        FirebaseDatabase.Database.database().reference().child("posts").observe(.childAdded) {
            (snapshot:DataSnapshot) in
            if let dict = snapshot.value as? [String: Any]
            {
                if dict["user_id"] as? String == Auth.auth().currentUser!.uid {
                    let photoUrlString = dict["photoUrl"] as? String
                    if photoUrlString != "" && photoUrlString != nil {
                        let storageRef = Storage.storage().reference(forURL: photoUrlString!)
                        storageRef.downloadURL(completion: { (url, error) in
                            do {
                                let data = try Data(contentsOf: url!)
                                let image = UIImage(data: data as Data)
                                self.imageArray.append(image!)
                                self.collectionView?.reloadData()
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
    
    func grabPhotos() {
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        if let fetchResult : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) {
            if fetchResult.count > 0 {
                for i in 0..<fetchResult.count {
                    imgManager.requestImage(for: fetchResult.object(at: i) , targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: requestOptions, resultHandler: {
                        image, error in self.imageArray.append(image!)
                    })
                }
            }
            else {
                print("You have no photos!")
                self.collectionView?.reloadData()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = imageArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.width / 3 - 1
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = imageArray[indexPath.row]
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
        print("Daaa")
    }
    
}
