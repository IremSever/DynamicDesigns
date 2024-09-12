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
    
    var shapeLayer: CAShapeLayer!
    var path = UIBezierPath()
    var startPoint: CGPoint?
    var isDrawing = false
    var panelSuccess: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getURL()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        imgSelected.addGestureRecognizer(longPressGesture)
        imgSelected.isUserInteractionEnabled = true
        
        createSavePanel()
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
                let image = UIImage(data: data)
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
              
              shapeLayer?.removeFromSuperlayer()
              path.removeAllPoints()
          
    }
    
    @IBAction func buttonCut(_ sender: Any) {
        if let croppedImage = cropImageToPath() {
            imgDesigned.image = croppedImage }
        
    }
    @IBAction func buttonSave(_ sender: Any) {
        guard let imageToSave = imgDesigned.image, let imageData = imageToSave.pngData() else {
            return
        }
        
        let uniqueFileName = UUID().uuidString
        let storageRef = storage.child("cropped_images/\(uniqueFileName).png")
        
        storageRef.putData(imageData, metadata: nil, completion: { _, error in
            guard error == nil else {
                print("*****Upload failed***** ", String(describing: error))
                return
            }
            
            storageRef.downloadURL(completion: { url, error in
                guard let url = url, error == nil else {
                    return
                }
                
                
                self.showSavePanel()
                
          
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.buttonRefresh(sender)
                }
            })
        })
    }
    
    // start drawing
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: imgSelected)
        
        if gesture.state == .began {
            // start drawing
            startPoint = location
            isDrawing = true
            path = UIBezierPath()
            path.move(to: location)
            createShapeLayer()
        } else if gesture.state == .changed, isDrawing {
            // drawing
            path.addLine(to: location)
            shapeLayer.path = path.cgPath
        } else if gesture.state == .ended {
            if isDrawing, let startPoint = startPoint {
                // end point
                path.addLine(to: startPoint)
                shapeLayer.path = path.cgPath
                isDrawing = false
            } else {
                // if dont touch reset
                shapeLayer.removeFromSuperlayer()
                isDrawing = false
            }
        }
    }
    
    // create shapelayer
    func createShapeLayer() {
        shapeLayer?.removeFromSuperlayer()  // delete last
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.yellow.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 8
        shapeLayer.lineDashPattern = [8, 5]
        imgSelected.layer.addSublayer(shapeLayer)
    }
    
    // cropped area looks white
    func cropImageToPath() -> UIImage? {
        guard let image = imgSelected.image else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(imgSelected.bounds.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // original image
        image.draw(in: imgSelected.bounds)
        
        // cropped
        context?.addPath(path.cgPath)
        context?.setFillColor(UIColor.white.cgColor)
        context?.fillPath()
        
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return croppedImage
    }
    
    
    func createSavePanel() {
        panelSuccess = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        panelSuccess.center = self.view.center
        panelSuccess.backgroundColor = UIColor.orange.withAlphaComponent(0.7)
        panelSuccess.layer.cornerRadius = 20
                
        let label = UILabel(frame: panelSuccess.bounds)
        label.text = "Saved!"
        label.textAlignment = .center
        label.textColor = .white
        panelSuccess.addSubview(label)
        
        panelSuccess.isHidden = true
        self.view.addSubview(panelSuccess)
    }
    
    func showSavePanel() {
        panelSuccess.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.panelSuccess.isHidden = true
        }
    }
}
