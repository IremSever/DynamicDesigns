//
//  ViewController.swift
//  DynamicDesigns
//
//  Created by İrem Sever on 11.09.2024.
//

import UIKit
import FirebaseRemoteConfig

class ViewController: UIViewController {

    private var viewBg1: UIView = {
        let view = UIView()
        view.backgroundColor = .cyan
        view.isHidden = true
        return view
    }()
    
    private var viewBg2: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        view.isHidden = true
        return view
    }()
    
    @IBOutlet weak var buttonStart: UIButton!
    private let removeConfig = RemoteConfig.remoteConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
//        view.addSubview(viewBg1)
//        view.addSubview(viewBg2)
        
        fetchValues()
    }
    
    override func viewDidLayoutSubviews() {
        viewBg1.frame = view.bounds
        viewBg2.frame = view.bounds
    }
    
    func fetchValues() {
        let defaults: [String: NSObject] = [
            "change_ui": false as NSObject
        ]
        removeConfig.setDefaults(defaults)
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        removeConfig.configSettings = settings
        
        chageUI(newUI: false)
        
        self.removeConfig.fetch(withExpirationDuration: 0, completionHandler: {status, error in
            if status == .success, error == nil {
                self.removeConfig.activate(completion: { success, error in
                    guard error == nil else {
                        print("Activation failed with error: \(String(describing: error))")
                        return
                    }
                    
                    if success {
                        let value = self.removeConfig.configValue(forKey: "change_ui").boolValue
                        print("*****Fetched Value:", value)
                        DispatchQueue.main.sync {
                            self.chageUI(newUI: value)
                        }
                    }
                })
            } else {
                print("error")
            }
        })
    }
    
    func chageUI(newUI: Bool) {
        if newUI {
            viewBg1.isHidden = false
        } else {
            viewBg2.isHidden = false
        }
    }
    
    
    @IBAction func buttonStart(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
       as! HomeViewController
          navigationController?.pushViewController(homeViewController, animated:
       true)
    }
}

