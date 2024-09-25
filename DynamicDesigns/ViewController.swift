//
//  ViewController.swift
//  DynamicDesigns
//
//  Created by İrem Sever on 11.09.2024.
//

import UIKit
import FirebaseRemoteConfig
import GoogleMobileAds

class ViewController: UIViewController, GADBannerViewDelegate, GADFullScreenContentDelegate {
    var viewBanner: GADBannerView!
    var viewInterstitial: GADInterstitialAd?
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
        viewBanner = GADBannerView(adSize: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(250))
        viewBanner.adUnitID = "ca-app-pub-3940256099942544/2435281174"
        viewBanner.rootViewController = self
        viewBanner.load(GADRequest())
        viewBanner.delegate = self
        
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest()) { ad, error in
            if let error = error {
                print("Failed to load interstitial ad: \(error.localizedDescription)")
                return
            }
            self.viewInterstitial = ad
            self.viewInterstitial?.fullScreenContentDelegate = self
        }
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
        if let viewInterstitial = viewInterstitial {
            viewInterstitial.present(fromRootViewController: self)
        } else {
            goToHomeViewController()
        }
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
    
    // ads to homeviewcontr
    func goToHomeViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    // Interstitial ads finish
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        goToHomeViewController()
    }
}

extension ViewController {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        addBannerViewToView(bannerView)
    }
}
