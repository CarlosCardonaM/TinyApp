//
//  AboutMeViewController.swift
//  TinyApp
//
//  Created by Carlos Cardona on 05/05/21.
//

import UIKit
import SafariServices

class AboutMeViewController: UIViewController {
    
    
    @IBOutlet weak var removeBtn: UIButton?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    static var instance = AboutMeViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: PurchaseManager.instance.IAP_REMOVE_ADS) {
            //TODO: remove from superview the label
            removeBtn?.removeFromSuperview()
        }
    }
    
    func configureSafari(url: String) {
        if let url = URL(string: url) {
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        }
    }
    
    @IBAction func twitterButton(_ sender: Any) {
        
        configureSafari(url: "https://twitter.com/cardonadev")
    }
    
    
    @IBAction func linkedinButton(_ sender: Any) {
        
        configureSafari(url: "https://www.linkedin.com/in/carloscardonadev")
        
    }
    
    
    @IBAction func webButton(_ sender: Any) {
        configureSafari(url: "https://www.carloscardona.me")
    }
    
    
    @IBAction func removeAdsButton(_ sender: Any) {
        
        activityIndicator.startAnimating()
        
        PurchaseManager.instance.purchaseRemoveAds { success in
            if success {
//                HomeViewController.instance.bannerView.removeFromSuperview()
                self.removeBtn?.removeFromSuperview()
                self.activityIndicator.stopAnimating()
            
            } else {
                // show alert to user
                self.activityIndicator.stopAnimating()
                print("FUUUUUUUUUUUUUUUUUUck")
            }
        }
    }
    
    
    @IBAction func restoreButtonPressed(_ sender: Any) {
        print("Hello there")
        
        PurchaseManager.instance.restorePurchases { success in
            if success {
                if UserDefaults.standard.bool(forKey: PurchaseManager.instance.IAP_REMOVE_ADS) {
                    //TODO: remove from superview the label
                    self.removeBtn?.removeFromSuperview()
                }
            }
        }
    }
}
