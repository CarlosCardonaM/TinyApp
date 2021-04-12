//
//  AboutMeViewController.swift
//  TinyApp
//
//  Created by Carlos Cardona on 06/04/21.
//

import UIKit
import SafariServices

class AboutMeViewController: UIViewController {
    
    let homeVC = HomeViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func SocialMediaButtonClicked(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "Twitter" {
            let vc = SFSafariViewController(url: URL(string: "https://twitter.com/cardonadev")!)
            present(vc, animated: true)
        } else {
            let vc = SFSafariViewController(url: URL(string: "https://www.linkedin.com/in/carloscardonadev/")!)
            present(vc, animated: true)
        }
    }
    
    
    @IBAction func hideAdsClicked(_ sender: Any) {
        homeVC.adsAreHidden = true
    }
}
