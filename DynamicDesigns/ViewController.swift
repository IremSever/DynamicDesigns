//
//  ViewController.swift
//  DynamicDesigns
//
//  Created by İrem Sever on 11.09.2024.
//

import UIKit
import FirebaseRemoteConfig

class ViewController: UIViewController {

    private var view1: UIView = {
        let view = UIView()
        view.backgroundColor = .cyan
        view.isHidden = true
        return view
    }()
    
    private var view2: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        view.isHidden = true
        return view
    }()
    
    private var view3: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        view.isHidden = true
        return view
    }()
    
    private let removeConfig = RemoteConfig.remoteConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(view1)
        view.addSubview(view2)
        view.addSubview(view3)
        
        fetchValues()
    }
    
    override func viewDidLayoutSubviews() {
        view1.frame = view.bounds
        view2.frame = view.bounds
        view3.frame = view.bounds
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
            view1.isHidden = false
        } else {
            view2.isHidden = false
        }
    }
}

