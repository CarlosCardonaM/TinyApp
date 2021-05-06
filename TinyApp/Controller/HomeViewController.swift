//
//  HomeViewController.swift
//  TinyApp
//
//  Created by Carlos Cardona on 05/04/21.
//

import UIKit
import CoreData
import GoogleMobileAds
import UserMessagingPlatform
import RxSwift
import RxRelay

class HomeViewController: UIViewController {

    @IBOutlet weak var totalAhorradoLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView?
    
    static var instance = HomeViewController()
    
    var adsAreHidden: Bool = false
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items: [Item]?
    
    var totalRelay = BehaviorRelay<Double>(value: 0)
    
    
    
    var counter = BehaviorRelay<Double>(value: 0)
    
    var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if UserDefaults.standard.bool(forKey: PurchaseManager.instance.IAP_REMOVE_ADS) {
            bannerView?.removeFromSuperview()
        } else {
            configureBannerView()
            requestConsent()
        }
        
        
        PurchaseManager.instance.restorePurchases { success in
            if success {
                if UserDefaults.standard.bool(forKey: PurchaseManager.instance.IAP_REMOVE_ADS) {
                    self.bannerView?.removeFromSuperview()
                } else {
                    self.configureBannerView()
                    self.requestConsent()
                }
            }
        }
        
        bannerView!.delegate = self
        
        totalRelay.subscribe(onNext: { [weak self] observer in
            self?.totalAhorradoLabel.text = "$" + String(observer)
            
            do {
                try self?.context.save()
            } catch {
                print("OH nooooo")
            }
            
        }).disposed(by: bag)
        
        fetchSavedCounters()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchItem()
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.bool(forKey: PurchaseManager.instance.IAP_REMOVE_ADS) {
            bannerView?.removeFromSuperview()
        } else {
            configureBannerView()
            requestConsent()
        }
        
        
        PurchaseManager.instance.restorePurchases { success in
            if success {
                if UserDefaults.standard.bool(forKey: PurchaseManager.instance.IAP_REMOVE_ADS) {
                    self.bannerView?.removeFromSuperview()
                } else {
                    self.configureBannerView()
                    self.requestConsent()
                }
            }
        }
        
        tableView.reloadData()
    }
    
    func fetchSavedCounters() {
        let context = AppDelegate.shared.persistentContainer.viewContext
        
        do {
            let totals: [Total] = try context.fetch(Total.fetchRequest())
            let doubleCounters: [Double] = totals.map({ Double($0.totalAhorrado) })
            let latestCounter = doubleCounters.last ?? 0
            self.totalRelay.accept(latestCounter)
            
        } catch {
            print("Error try mapping and saving the latest counter::::Error: ", error)
        }
    }
    
    func save(total: Double) {
        
        let context = AppDelegate.shared.persistentContainer.viewContext
        
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: "Total", into: context)
        managedObject.setValue(total, forKey: "totalAhorrado")
        
        do {
            try context.save()
        } catch {
            print("Error saving context::::Error: ", error)
        }
        
    }
    
    func fetchItem() {
        do {
            items = try self.context.fetch(Item.fetchRequest())
        } catch {
            
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func update( completion: @escaping () -> ()) {
        
        completion()
        
        do {
            try context.save()
            fetchItem()
        } catch {
            print("::: Error trying saving to coreData (deleting)")
        }
        
        DispatchQueue.main.async {
            self.totalAhorradoLabel.text = String(self.counter.value)
        }
    }
    
    func updateItem(item: Item, newSaving: Double) {
        
        do {
            try context.save()
            fetchItem()
        } catch {
            print("::: Error trying saving to coreData (deleting)")
        }
        
        DispatchQueue.main.async {
            self.totalAhorradoLabel.text = String(self.counter.value)
        }
        
        
        
    }
    @IBAction func addBarButtonItem(_ sender: Any) {
       
        let addViewController = storyboard?.instantiateViewController(identifier: "AddViewController") as! AddViewController
        
        addViewController.addGastoObservable.subscribe(onNext: { [weak self] one in
            
            guard let total = self?.totalRelay else { return }
            
            total.accept(total.value + one)
            
            do {
                try self?.context.save()
            } catch {
                
            }
        }, onCompleted: { [weak self] in
            print("completed")
            
            guard let self = self else { return }
            self.save(total: Double(self.totalRelay.value))
            self.fetchItem()
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: bag)
        
        navigationController?.pushViewController(addViewController, animated: true)
    }
    
    
    @IBAction func aboutMeButtonClicked(_ sender: Any) {
    }
}


// MARK: - TableView Deleate and Datasource Methods

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        items?.count ?? 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let item = items![indexPath.row]

        if items?.count == 0 {
            cell.textLabel?.text = "Aun no hay gastos añadidos"
        }

        cell.textLabel?.text = item.nombre
        cell.detailTextLabel?.text = String(item.ahorro)

        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            let itemToRemove = self.items![indexPath.row]
            
            self.context.delete(itemToRemove)
            
            
            self.totalRelay.accept(
                self.totalRelay.value - itemToRemove.ahorro
            )

            do {
                try self.context.save()
            } catch {

            }
            self.fetchItem()
        }

        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

// MARK: - ADMob Mehtods

// https://f4e7a3284.app-ads-txt.com

extension HomeViewController: GADBannerViewDelegate {

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print(":::::\(error.localizedDescription)")
    }

    func requestConsent() {

        let parameters = UMPRequestParameters()
        let debugSettings = UMPDebugSettings()
        debugSettings.testDeviceIdentifiers = ["C4655FEF-78E1-4912-BD0E-E42A1279880D"]
        debugSettings.geography = UMPDebugGeography.notEEA
        parameters.debugSettings = debugSettings
        // Create a UMPRequestParameters object.
//        let parameters = UMPRequestParameters()
//        // Set tag for under age of consent. Here false means users are not under age.
        parameters.tagForUnderAgeOfConsent = false

        // Request an update to the consent information.
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(
            with: parameters,
            completionHandler: { error in
                if error != nil {
                    // Handle the error.
                    print(":::: OOH no \(error!.localizedDescription)")
                } else {
                    // The consent information state was updated.
                    // You are now ready to check if a form is
                    // available.
                    let formStatus = UMPConsentInformation.sharedInstance.formStatus
                    if formStatus == UMPFormStatus.available {
                        self.loadForm()
                    }
                }
            })
    }
    
    func loadForm() {
        UMPConsentForm.load(
            completionHandler: { form, loadError in
                if loadError != nil {
                    // Handle the error
                    print("::: OOOOH SHIIIIT")
                } else {
                    // Present the form
                    if UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatus.required {
                        form?.present(
                            from: self,
                            completionHandler: { dismissError in
                                if UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatus.obtained {
                                    // App can start requesting ads.
                                    self.configureBannerView()
                                } else {
                                    self.requestConsent()
                                }
                            })
                    } else {
                        // Keep the form available for changes to user consent.
                    }
                }
            })
    }
    
    func configureBannerView() {
        bannerView?.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView?.load(GADRequest())
        bannerView?.backgroundColor = .secondarySystemBackground
        bannerView?.rootViewController = self
    }
}
