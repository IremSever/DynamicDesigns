//
//  HomeViewController.swift
//  DynamicDesigns
//
//  Created by İrem Sever on 12.09.2024.
//

import Foundation
import UIKit
import FirebaseStorage


class HomeViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    private let storage = Storage.storage().reference()
    
    @IBOutlet weak var imgSelected: UIImageView!
    @IBOutlet weak var imgDesigned: UIImageView!
    @IBOutlet weak var lblLink: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getURL()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getURL()
    }

    
    func getURL() {
       guard let stringUrl = UserDefaults.standard.value(forKey: "url") as? String,
             let url = URL(string: stringUrl) else {
               print("No URL stored in UserDefaults or URL is invalid")
               return
       }
        lblLink.text = stringUrl
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
         guard let data = data, error == nil else {
           print("Error downloading image:", error?.localizedDescription ?? "Unknown error")
           return
         }
         DispatchQueue.main.async {
           let image = UIImage(data:
    data)
           self.imgSelected.image = image
         }
       })
       task.resume()
     }
 
    @IBAction func buttonAdd(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true, completion: nil)
            
            guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
                return
            }
            guard let imageData = image.pngData() else {
                return
            }
            
            let uniqueFileName = UUID().uuidString
            let storageRef = storage.child("images/\(uniqueFileName).png")
            
            storageRef.putData(imageData, metadata: nil, completion: { _, error in
                guard error == nil else {
                    print("*****Upload failed***** ", String(describing: error))
                    return
                }
                storageRef.downloadURL(completion: { url, error in
                    guard let url = url, error == nil else {
                        return
                    }
                    
                    let stringUrl = url.absoluteString
                    print("*****Download URL*****", stringUrl)
                    UserDefaults.standard.set(stringUrl, forKey: "url" )
                    
                    DispatchQueue.main.async {
                        self.getURL()
                    }
                })
            })
        }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonRefresh(_ sender: Any) {
        imgSelected.image = UIImage(named: "upload")
        imgDesigned.image = UIImage(named: "download")
        UserDefaults.standard.removeObject(forKey: "url")
        lblLink.text = ""
    }
    
    @IBAction func buttonCut(_ sender: Any) {
        
    }
    @IBAction func buttonSave(_ sender: Any) {
    }
    
}

