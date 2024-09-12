//
//  ViewController.swift
//  DynamicDesigns
//
//  Created by İrem Sever on 11.09.2024.
//

import UIKit
import FirebaseRemoteConfig
import GoogleMobileAds

class ViewController: UIViewController, GADBannerViewDelegate {
    var bannerView: GADBannerView!
    private var viewBg1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cyan.withAlphaComponent(1)
        view.isHidden = true
        return view
    }()
    
    private var viewBg2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemIndigo.withAlphaComponent(1)
        view.isHidden = true
        return view
    }()
    
    @IBOutlet weak var buttonStart: UIButton!
    private let removeConfig = RemoteConfig.remoteConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        view.addSubview(viewBg1)
        view.addSubview(viewBg2)
        view.addSubview(buttonStart)
        //google mobile ads
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        //addBannerViewToView(bannerView)
        
        //bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
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
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: view.safeAreaLayoutGuide,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
}

extension ViewController {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      addBannerViewToView(bannerView)
    }
   
}

