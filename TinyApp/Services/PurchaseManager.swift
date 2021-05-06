//
//  PurchaseManager.swift
//  TinyApp
//
//  Created by Carlos Cardona on 05/05/21.

typealias CompletionHandler = (_ success: Bool) -> ()
//
import Foundation
import StoreKit

class PurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    static let instance = PurchaseManager()
    
    let IAP_REMOVE_ADS = "com.tinyApp.eliminar.publicidad"
    
    
    var productsRequest: SKProductsRequest!
    var products = [SKProduct]()
    var transactionComplete: CompletionHandler?
    
    func fetchProducts() {
        let productIds = NSSet(object: IAP_REMOVE_ADS) as! Set<String>
        productsRequest = SKProductsRequest(productIdentifiers: productIds)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func purchaseRemoveAds(onComplete: @escaping CompletionHandler) {
        if SKPaymentQueue.canMakePayments() && products.count > 0 {
            
            transactionComplete = onComplete
            
            let removeAdsProduct = products[0]
            
            let payment = SKPayment(product: removeAdsProduct)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
        } else{
            onComplete(false)
        }
    }
    
    func restorePurchases(onComplete: @escaping CompletionHandler) {
        
        // TODO test all scenarios without checking if the user can make payments
//        SKPaymentQueue.default().restoreCompletedTransactions()
        
        if SKPaymentQueue.canMakePayments() {
            transactionComplete = onComplete
            SKPaymentQueue.default().add(self)
            
        } else {
            onComplete(false)
        }
        
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        if response.products.count > 0 {
            
            print(response.products.debugDescription)
            products = response.products
        } else {
            print("No hayyy")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                if transaction.payment.productIdentifier == IAP_REMOVE_ADS {
                    UserDefaults.standard.set(true, forKey: IAP_REMOVE_ADS)
                    transactionComplete?(true)
                }
                break
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionComplete?(false)
                break
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                if transaction.payment.productIdentifier == IAP_REMOVE_ADS {
                    UserDefaults.standard.set(true, forKey: IAP_REMOVE_ADS)
                    transactionComplete?(true)
                }
            case .purchasing:
                print("HOLLLLLIIIII")
            default:
                transactionComplete?(false)
                break
            }
            
        }
        
    }
    
}
