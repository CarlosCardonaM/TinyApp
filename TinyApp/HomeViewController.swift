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

class HomeViewController: UIViewController {

    @IBOutlet weak var totalAhorradoLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var adsAreHidden: Bool = false
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items: [Item]?
    var total: Total?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if adsAreHidden == false {
            requestConsent()
            
            configureBannerView()
        } else {
            bannerView.isHidden = true
        }
        
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(adsAreHidden)
        
        if adsAreHidden == false {
            requestConsent()
            
            configureBannerView()
        } else {
            bannerView.isHidden = true
        }
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
//        parameters.tagForUnderAgeOfConsent = false

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
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.load(GADRequest())
        bannerView.backgroundColor = .secondarySystemBackground
        bannerView.rootViewController = self
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
    
    func updateItem(item: Item, newSaving: Double) {
        item.totalAhorrado += newSaving
        
        do {
            try context.save()
            fetchItem()
        } catch {
            print("::: Error trying saving to coreData (deleting)")
        }
        
        totalAhorradoLabel.text = String(item.totalAhorrado)
        
        
    }
    @IBAction func addBarButtonItem(_ sender: Any) {
        let alert = UIAlertController(title: "Añade", message: "Agreag un nuevo Gasto", preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        alert.textFields?.first?.becomeFirstResponder()
        alert.textFields?.first?.autocapitalizationType = .sentences
        alert.textFields?.first?.placeholder = "Nombre de gasto"
        
        alert.textFields?.last?.keyboardType = .numberPad
        alert.textFields?.last?.placeholder = "Monto de gasto"
        
        alert.addAction(UIAlertAction(title: "Añadir", style: .default, handler: { (action) in
            
            guard let nombreTextField = alert.textFields?.first, let nombreText = nombreTextField.text, !nombreText.isEmpty, let gastoTextField = alert.textFields?.last, let gastoText = gastoTextField.text, !gastoText.isEmpty else {
                print("Auch")
                return
            }
            
            let newItem = Item(context: self.context)
            newItem.nombre = nombreText
            newItem.gasto = Double(gastoText)!
            newItem.ahorro = Double(gastoText)! * 0.03
            self.updateItem(item: newItem, newSaving: Double(gastoText)! * 0.03)
//            newItem.totalAhorrado = newItem.totalAhorrado + Double(gastoText)! * 0.03
            
            
            let total = Total(context: self.context)
            
            total.totalAhorrado += Double(gastoText)! * 0.03
            total.totalGastado += Double(gastoText)!
            
            do {
                try self.context.save()
            } catch {
                
            }
            
            self.fetchItem()
            
            print(newItem.totalAhorrado)
            DispatchQueue.main.async {
                self.totalAhorradoLabel.text = String(newItem.totalAhorrado)
            }
            
            
//            self.totalAhorradoLabel.text = String(total.totalAhorrado)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    
    @IBAction func aboutMeButtonClicked(_ sender: Any) {
        let vc = AboutMeViewController()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true)
    }
}


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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        let alert = UIAlertController(title: "Edita", message: "Edita tu Gasto", preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        alert.textFields?.first?.becomeFirstResponder()
        alert.textFields?.first?.autocapitalizationType = .sentences
        
        alert.textFields?.last?.keyboardType = .numberPad
        
        alert.addAction(UIAlertAction(title: "Añadir", style: .default, handler: { (action) in
            
            
            
            guard let nombreTextField = alert.textFields?.first, let nombreText = nombreTextField.text, !nombreText.isEmpty, let gastoTextField = alert.textFields?.last, let gastoText = gastoTextField.text, !gastoText.isEmpty else {
                print("Auch")
                return
            }
            
            let itemToUpdate = self.items![indexPath.row]
            
            
            nombreTextField.text = itemToUpdate.nombre
            gastoTextField.text = String(itemToUpdate.gasto)
            
            
            itemToUpdate.nombre = nombreText
            itemToUpdate.gasto = Double(gastoText)!
            itemToUpdate.ahorro = Double(gastoText)! * 0.03
            
            
            self.total?.totalAhorrado += Double(gastoText)! * 0.03
            self.total?.totalGastado += Double(gastoText)!
            
            
            
            
            do {
                try self.context.save()
            } catch {
                
            }
            
            self.fetchItem()
            
            self.totalAhorradoLabel.text = String((self.total?.totalAhorrado)!)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            let itemToRemove = self.items![indexPath.row]
            
            self.context.delete(itemToRemove)
            self.total?.totalAhorrado -= itemToRemove.ahorro
            self.total?.totalGastado -= itemToRemove.gasto
            
            do {
                try self.context.save()
            } catch {
                
            }
            self.fetchItem()
            
//            self.totalAhorradoLabel.text = String((self.total?.totalAhorrado)!)
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
}


extension HomeViewController: GADBannerViewDelegate {
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print(":::::\(error.localizedDescription)")
    }
}
